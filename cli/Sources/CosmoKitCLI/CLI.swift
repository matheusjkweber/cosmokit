//
//  main.swift
//  cosmokit CLI
//
//  Scriptable access to the same simulator operations the app performs, for
//  Makefiles, git hooks and CI. Once a team has `cosmokit capture` in a
//  script, the tool is part of the workflow rather than something they
//  remember to open.
//

import Foundation

public enum CLI {
    public static let version = "0.1.0"

    static func printUsage() {
        print("""
        cosmokit \(CLI.version) — drive the iOS Simulator from the command line

        USAGE
          cosmokit <command> [options]

        COMMANDS
          list                        List available simulators
          boot [name|udid]            Boot a simulator (default: first available)
          shutdown [name|udid]        Shut a simulator down (default: booted)
          capture [name|udid]         Screenshot to a file
          record [name|udid]          Record video until you press Ctrl-C
          location <lat> <lon> [dev]  Set the simulator's GPS position
          open <url> [name|udid]      Open a deep link
          erase [name|udid]           Erase a simulator back to a fresh install
          help                        Show this message

        OPTIONS
          --output <path>             Where to write a capture (default: ./)

        EXAMPLES
          cosmokit capture --output ./screenshots
          cosmokit location -22.9068 -43.1729
          cosmokit open "myapp://item/42"
        """)
    }

/// Pulls output-related flags out of the argument list, returning the rest.
    public static func extractFlags(_ args: [String]) -> (json: Bool, output: String?, rest: [String]) {
        var json = false
        var output: String?
        var rest: [String] = []
        var index = 0
        while index < args.count {
            switch args[index] {
            case "--json":
                json = true
                index += 1
                continue
            case "--output" where index + 1 < args.count:
                output = args[index + 1]
                index += 2
                continue
            default:
                break
            }
            rest.append(args[index])
            index += 1
        }
        return (json, output, rest)
    }

    public static func extractOutput(_ args: [String]) -> (output: String?, rest: [String]) {
        let flags = extractFlags(args)
        return (flags.output, flags.rest)
    }

    public static func timestampedPath(directory: String?, prefix: String, ext: String, deviceName: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        let safeName = deviceName.replacingOccurrences(of: " ", with: "-")
        let filename = "\(prefix)-\(safeName)-\(formatter.string(from: Date())).\(ext)"
        let base = directory ?? FileManager.default.currentDirectoryPath
        return URL(fileURLWithPath: base).appendingPathComponent(filename).path
    }

    public static func run(_ rawArgs: [String]) {
        let flags = extractFlags(rawArgs)
        guard let command = flags.rest.first else {
            printUsage()
            exit(0)
        }
        let output = flags.output
        let json = flags.json
        let args = Array(flags.rest.dropFirst())

    do {
        switch command {
        case "help", "--help", "-h":
            printUsage()

        case "version", "--version":
            if json {
                writeJSON(Envelope(ok: true, payload: VersionPayload(version: CLI.version)))
            } else {
                print(CLI.version)
            }

        case "list":
            let devices = try Simctl.devices()
                .filter { $0.isAvailable }
                .sorted { $0.name < $1.name }
            if json {
                let payload = devices.map {
                    DevicePayload(udid: $0.udid, name: $0.name, state: $0.state, booted: $0.isBooted, available: $0.isAvailable)
                }
                writeJSON(Envelope(ok: true, payload: DevicesPayload(devices: payload)))
                return
            }
            guard !devices.isEmpty else {
                print("No available simulators.")
                return
            }
            for device in devices {
                let marker = device.isBooted ? "●" : "○"
                print("\(marker) \(device.name)  \(device.udid)  \(device.state)")
            }

        case "boot":
            let device: Device
            if let query = args.first {
                device = try Simctl.resolveDevice(query)
            } else if let firstShutdown = try Simctl.devices().first(where: { $0.isAvailable && !$0.isBooted }) {
                device = firstShutdown
            } else {
                throw SimctlError(message: "no available simulator to boot")
            }
            if device.isBooted {
                print("Already booted: \(device.name)")
            } else {
                try Simctl.run(["boot", device.udid])
                print("Booted \(device.name)")
            }

        case "shutdown":
            let device = try Simctl.resolveDevice(args.first)
            try Simctl.run(["shutdown", device.udid])
            print("Shut down \(device.name)")

        case "capture":
            let device = try Simctl.resolveDevice(args.first)
            let path = timestampedPath(
                directory: output, prefix: "CosmoKit-Screenshot", ext: "png", deviceName: device.name
            )
            try Simctl.run(["io", device.udid, "screenshot", path])
            print(path)

        case "record":
            let device = try Simctl.resolveDevice(args.first)
            let path = timestampedPath(
                directory: output, prefix: "CosmoKit-Recording", ext: "mp4", deviceName: device.name
            )
            print("Recording \(device.name). Press Ctrl-C to stop.")
            // simctl writes the file when it receives SIGINT, so hand the
            // terminal's Ctrl-C straight through to it.
            try Simctl.run(["io", device.udid, "recordVideo", path])
            print(path)

        case "location":
            guard args.count >= 2, let lat = Double(args[0]), let lon = Double(args[1]) else {
                throw SimctlError(message: "usage: cosmokit location <lat> <lon> [name|udid]")
            }
            let device = try Simctl.resolveDevice(args.count > 2 ? args[2] : nil)
            try Simctl.run(["location", device.udid, "set", "\(lat),\(lon)"])
            print("Set \(device.name) to \(lat), \(lon)")

        case "open":
            guard let url = args.first else {
                throw SimctlError(message: "usage: cosmokit open <url> [name|udid]")
            }
            let device = try Simctl.resolveDevice(args.count > 1 ? args[1] : nil)
            try Simctl.run(["openurl", device.udid, url])
            print("Opened \(url) on \(device.name)")

        case "erase":
            let device = try Simctl.resolveDevice(args.first)
            // simctl refuses to erase a booted device.
            _ = try? Simctl.run(["shutdown", device.udid])
            try Simctl.run(["erase", device.udid])
            print("Erased \(device.name)")

        default:
            if json {
                writeFailure(CommandError(code: .unknownCommand, message: "Unknown command: \(command)"))
            }
            FileHandle.standardError.write(Data("Unknown command: \(command)\n\n".utf8))
            printUsage()
            exit(1)
        }
    } catch {
        if json {
            writeFailure(CommandError(code: errorCode(for: error), message: error.localizedDescription))
        }
        FileHandle.standardError.write(Data("cosmokit: \(error.localizedDescription)\n".utf8))
        exit(1)
    }
    }

    private static func writeJSON<Payload: Encodable>(_ envelope: Envelope<Payload>) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            let data = try encoder.encode(envelope)
            print(String(decoding: data, as: UTF8.self))
        } catch {
            FileHandle.standardError.write(Data("cosmokit: could not encode JSON: \(error.localizedDescription)\n".utf8))
            exit(1)
        }
    }

    private static func writeFailure(_ error: CommandError) {
        writeJSON(Envelope<EmptyPayload>(ok: false, error: error))
    }

    private static func errorCode(for error: Error) -> ErrorCode {
        let message = error.localizedDescription.lowercased()
        if message.hasPrefix("usage:") { return .usage }
        if message.contains("no simulator matching") { return .deviceNotFound }
        if message.contains("no booted simulator") || message.contains("no available simulator") {
            return .noSimulator
        }
        return .simctlFailed
    }
}

public struct VersionPayload: Encodable {
    public let version: String
    public init(version: String) { self.version = version }
}

public struct DevicePayload: Encodable {
    public let udid: String
    public let name: String
    public let state: String
    public let booted: Bool
    public let available: Bool

    public init(udid: String, name: String, state: String, booted: Bool, available: Bool) {
        self.udid = udid
        self.name = name
        self.state = state
        self.booted = booted
        self.available = available
    }
}

public struct DevicesPayload: Encodable {
    public let devices: [DevicePayload]
    public init(devices: [DevicePayload]) { self.devices = devices }
}

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

/// What a command produced. `human` is the exact line the CLI has always
/// printed; `json` is the same result as an encodable payload.
public struct CommandOutcome {
    public let human: String
    public let jsonData: () throws -> Data

    public init<Payload: Encodable>(human: String, json: Payload) {
        self.human = human
        self.jsonData = {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys]
            return try encoder.encode(Envelope(ok: true, payload: json))
        }
    }
}

public struct CLIError: LocalizedError {
    public let commandError: CommandError

    public var errorDescription: String? { commandError.message }

    public init(commandError: CommandError) {
        self.commandError = commandError
    }
}

public enum CLI {
    public static let version = "0.1.0"
    public static var runSimctlForTesting: (_ arguments: [String]) throws -> String = { try Simctl.run($0) }
    public static var resolveDeviceForTesting: (_ query: String?) throws -> Device = { try Simctl.resolveDevice($0) }

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
          apps [name|udid]            List installed apps
          install <path> [name|udid]  Install an app bundle
          uninstall <bundle> [name|udid] Uninstall an app
          launch <bundle> [name|udid] Launch an app
          terminate <bundle> [name|udid] Terminate an app
          container <bundle> [kind] [name|udid] Get an app container path
          appearance [light|dark] [name|udid] Set or read appearance
          statusbar [flags] [name|udid] Set status bar overrides
          statusbar-clear [name|udid]   Clear status bar overrides
          permission <action> <service> [bundle] [name|udid] Set privacy permission
          biometric-enroll <on|off> [name|udid] Set biometric enrollment
          biometric-match [match|nomatch] [name|udid] Trigger biometric result
          mcp                         Run as an MCP server over stdio (for AI agents)
          help                        Show this message

        OPTIONS
          --output <path>             Where to write a capture (default: ./)
          --json                      Emit machine-readable JSON on stdout
          --duration <seconds>        Recording duration (for record)

        EXAMPLES
          cosmokit capture --output ./screenshots
          cosmokit location -22.9068 -43.1729
          cosmokit open "myapp://item/42"
          cosmokit --json list
        """)
    }

/// Pulls output-related flags out of the argument list, returning the rest.
    public static func extractFlags(_ args: [String]) -> (json: Bool, output: String?, duration: String?, rest: [String]) {
        var json = false
        var output: String?
        var duration: String?
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
            case "--duration":
                duration = index + 1 < args.count ? args[index + 1] : ""
                index += index + 1 < args.count ? 2 : 1
                continue
            default:
                break
            }
            rest.append(args[index])
            index += 1
        }
        return (json, output, duration, rest)
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

        do {
            if command == "mcp" {
                MCPServer.serve()
                return
            }
            let outcome = try perform(
                command: command,
                args: Array(flags.rest.dropFirst()),
                output: flags.output,
                duration: try parseDuration(flags.duration)
            )
            if flags.json {
                writeJSONData(try outcome.jsonData())
            } else {
                print(outcome.human)
            }
        } catch {
            if flags.json {
                let commandError = (error as? CLIError)?.commandError
                    ?? CommandError(code: errorCode(for: error), message: error.localizedDescription)
                writeFailure(commandError)
            }
            if let commandError = (error as? CLIError)?.commandError,
               commandError.code == .unknownCommand, !flags.json {
                FileHandle.standardError.write(Data("Unknown command: \(commandError.message.replacingOccurrences(of: "Unknown command: ", with: ""))\n\n".utf8))
                printUsage()
            } else {
                FileHandle.standardError.write(Data("cosmokit: \(error.localizedDescription)\n".utf8))
            }
            exit(1)
        }
    }

    public static func perform(command: String, args: [String], output: String?) throws -> CommandOutcome {
        try perform(command: command, args: args, output: output, duration: nil)
    }

    public static func perform(command: String, args: [String], output: String?, duration: Double?) throws -> CommandOutcome {
        switch command {
        case "help", "--help", "-h":
            return CommandOutcome(human: usageText(), json: EmptyPayload())

        case "version", "--version":
            return CommandOutcome(human: CLI.version, json: VersionPayload(version: CLI.version))

        case "list":
            let devices = try devices()
                .filter { $0.isAvailable }
                .sorted { $0.name < $1.name }
            let human = devices.isEmpty
                ? "No available simulators."
                : devices.map { "\($0.isBooted ? "●" : "○") \($0.name)  \($0.udid)  \($0.state)" }.joined(separator: "\n")
            let payload = devices.map {
                DevicePayload(udid: $0.udid, name: $0.name, state: $0.state, booted: $0.isBooted, available: $0.isAvailable)
            }
            return CommandOutcome(human: human, json: DevicesPayload(devices: payload))

        case "boot":
            let device: Device
            if let query = args.first {
                device = try resolveDevice(query)
            } else if let firstShutdown = try devices().first(where: { $0.isAvailable && !$0.isBooted }) {
                device = firstShutdown
            } else {
                throw CLIError(commandError: CommandError(code: .noSimulator, message: "no available simulator to boot"))
            }
            let alreadyBooted = device.isBooted
            if !alreadyBooted {
                try runSimctl(["boot", device.udid])
            }
            return CommandOutcome(
                human: alreadyBooted ? "Already booted: \(device.name)" : "Booted \(device.name)",
                json: BootPayload(udid: device.udid, name: device.name, alreadyBooted: alreadyBooted)
            )

        case "shutdown":
            let device = try resolveDevice(args.first)
            try runSimctl(["shutdown", device.udid])
            return CommandOutcome(human: "Shut down \(device.name)", json: ShutdownPayload(udid: device.udid, name: device.name))

        case "capture":
            let device = try resolveDevice(args.first)
            let path = timestampedPath(directory: output, prefix: "CosmoKit-Screenshot", ext: "png", deviceName: device.name)
            try runSimctl(["io", device.udid, "screenshot", path])
            return CommandOutcome(human: path, json: CapturePayload(udid: device.udid, name: device.name, path: path))

        case "record":
            let device = try resolveDevice(args.first)
            let path = timestampedPath(directory: output, prefix: "CosmoKit-Recording", ext: "mp4", deviceName: device.name)
            let human = "Recording \(device.name). Press Ctrl-C to stop.\n\(path)"
            try Simctl.runInterruptible(["io", device.udid, "recordVideo", path], stopAfter: duration)
            return CommandOutcome(human: human, json: RecordPayload(udid: device.udid, name: device.name, path: path))

        case "location":
            let location = try parseLocation(args)
            let device = try resolveDevice(location.query)
            try runSimctl(["location", device.udid, "set", "\(location.latitude),\(location.longitude)"])
            return CommandOutcome(human: "Set \(device.name) to \(location.latitude), \(location.longitude)", json: LocationPayload(udid: device.udid, name: device.name, latitude: location.latitude, longitude: location.longitude))

        case "open":
            guard let url = args.first else {
                throw CLIError(commandError: CommandError(code: .usage, message: "usage: cosmokit open <url> [name|udid]"))
            }
            let device = try resolveDevice(args.count > 1 ? args[1] : nil)
            try runSimctl(["openurl", device.udid, url])
            return CommandOutcome(human: "Opened \(url) on \(device.name)", json: OpenPayload(udid: device.udid, name: device.name, url: url))

        case "erase":
            let device = try resolveDevice(args.first)
            _ = try? runSimctl(["shutdown", device.udid])
            try runSimctl(["erase", device.udid])
            return CommandOutcome(human: "Erased \(device.name)", json: ErasePayload(udid: device.udid, name: device.name))

        case "apps":
            let device = try resolveDevice(args.first)
            let apps = try parseInstalledApps(runSimctl(["listapps", device.udid]))
            let human = apps.map { "\($0.bundleID)  \($0.name)  \($0.path)" }.joined(separator: "\n")
            return CommandOutcome(human: human, json: AppsPayload(udid: device.udid, name: device.name, apps: apps))

        case "install":
            guard let path = args.first, !path.isEmpty else {
                throw CLIError(commandError: CommandError(code: .usage, message: "usage: cosmokit install <path> [name|udid] (missing path)"))
            }
            let device = try resolveDevice(args.count > 1 ? args[1] : nil)
            try runSimctl(["install", device.udid, path])
            return CommandOutcome(human: "Installed \(path) on \(device.name)", json: InstallPayload(udid: device.udid, name: device.name, path: path))

        case "uninstall":
            let bundleID = try requiredBundle(args, command: "uninstall")
            let device = try resolveDevice(args.count > 1 ? args[1] : nil)
            try runSimctl(["uninstall", device.udid, bundleID])
            return CommandOutcome(human: "Uninstalled \(bundleID) from \(device.name)", json: UninstallPayload(udid: device.udid, name: device.name, bundleID: bundleID))

        case "launch":
            let bundleID = try requiredBundle(args, command: "launch")
            let device = try resolveDevice(args.count > 1 ? args[1] : nil)
            let simctlOutput = try runSimctl(["launch", device.udid, bundleID])
            let pid = simctlOutput.split(whereSeparator: { $0 == ":" || $0 == " " || $0 == "\n" }).compactMap { Int($0) }.first
            return CommandOutcome(human: simctlOutput.trimmingCharacters(in: .whitespacesAndNewlines), json: LaunchPayload(udid: device.udid, name: device.name, bundleID: bundleID, pid: pid))

        case "terminate":
            let bundleID = try requiredBundle(args, command: "terminate")
            let device = try resolveDevice(args.count > 1 ? args[1] : nil)
            try runSimctl(["terminate", device.udid, bundleID])
            return CommandOutcome(human: "Terminated \(bundleID) on \(device.name)", json: TerminatePayload(udid: device.udid, name: device.name, bundleID: bundleID))

        case "container":
            let bundleID = try requiredBundle(args, command: "container")
            let kind: String
            if args.count < 2 {
                kind = "app"
            } else if ["app", "data", "groups"].contains(args[1]) {
                kind = args[1]
            } else {
                throw CLIError(commandError: CommandError(code: .usage, message: "usage: cosmokit container <bundle> [app|data|groups] [name|udid]"))
            }
            let device = try resolveDevice(args.count > 2 ? args[2] : nil)
            let simctlArgs = kind == "app" ? ["get_app_container", device.udid, bundleID] : ["get_app_container", device.udid, bundleID, kind]
            let path = try runSimctl(simctlArgs).trimmingCharacters(in: .whitespacesAndNewlines)
            return CommandOutcome(human: path, json: ContainerPayload(udid: device.udid, name: device.name, bundleID: bundleID, kind: kind, path: path))

        case "appearance":
            let value = args.first.flatMap { ["light", "dark"].contains($0) ? $0 : nil }
            if args.first != nil && value == nil {
                throw CLIError(commandError: CommandError(code: .usage, message: "appearance must be one of: light, dark"))
            }
            let device = try resolveDevice(value == nil ? args.first : (args.count > 1 ? args[1] : nil))
            let simctlArgs = value.map { ["ui", device.udid, "appearance", $0] } ?? ["ui", device.udid, "appearance"]
            let appearance = try runSimctl(simctlArgs).trimmingCharacters(in: .whitespacesAndNewlines)
            return CommandOutcome(human: appearance, json: AppearancePayload(udid: device.udid, name: device.name, appearance: appearance))

        case "statusbar":
            let parsed = try parseStatusBar(args)
            let device = try resolveDevice(parsed.device)
            guard !parsed.overrides.isEmpty else {
                throw CLIError(commandError: CommandError(code: .usage, message: "statusbar requires at least one override"))
            }
            var simctlArgs = ["status_bar", device.udid, "override"]
            for (flag, value) in parsed.overrides { simctlArgs += ["--\(flag)", value] }
            try runSimctl(simctlArgs)
            return CommandOutcome(human: "Overrode status bar on \(device.name)", json: StatusBarPayload(udid: device.udid, name: device.name, overrides: parsed.overrides))

        case "statusbar-clear":
            let device = try resolveDevice(args.first)
            try runSimctl(["status_bar", device.udid, "clear"])
            return CommandOutcome(human: "Cleared status bar on \(device.name)", json: StatusBarClearPayload(udid: device.udid, name: device.name))

        case "permission":
            let permission = try parsePermission(args)
            let device = try resolveDevice(permission.device)
            var simctlArgs = ["privacy", device.udid, permission.action, permission.service]
            if let bundleID = permission.bundleID { simctlArgs.append(bundleID) }
            try runSimctl(simctlArgs)
            return CommandOutcome(human: "Set \(permission.action) \(permission.service) on \(device.name)", json: PermissionPayload(udid: device.udid, name: device.name, action: permission.action, service: permission.service, bundleID: permission.bundleID))

        case "biometric-enroll":
            guard let raw = args.first, ["on", "off"].contains(raw) else {
                throw CLIError(commandError: CommandError(code: .usage, message: "biometric-enroll requires on or off"))
            }
            let device = try resolveDevice(args.count > 1 ? args[1] : nil)
            let value = raw == "on" ? "1" : "0"
            try runSimctl(["spawn", device.udid, "notifyutil", "-s", "com.apple.BiometricKit.enrollmentChanged", value])
            try runSimctl(["spawn", device.udid, "notifyutil", "-p", "com.apple.BiometricKit.enrollmentChanged"])
            return CommandOutcome(human: "Biometric enrollment \(raw) on \(device.name)", json: BiometricEnrollPayload(udid: device.udid, name: device.name, enrolled: raw == "on"))

        case "biometric-match":
            let result = args.first.flatMap { ["match", "nomatch"].contains($0) ? $0 : nil } ?? "match"
            if args.first != nil && !["match", "nomatch"].contains(args.first!) {
                throw CLIError(commandError: CommandError(code: .usage, message: "biometric-match result must be match or nomatch"))
            }
            let device = try resolveDevice(result == args.first ? (args.count > 1 ? args[1] : nil) : args.first)
            let notification = result == "match" ? "com.apple.BiometricKit_Sim.fingerTouch.match" : "com.apple.BiometricKit_Sim.fingerTouch.nomatch"
            try runSimctl(["spawn", device.udid, "notifyutil", "-p", notification])
            return CommandOutcome(human: "Biometric \(result) on \(device.name)", json: BiometricMatchPayload(udid: device.udid, name: device.name, result: result))

        default:
            throw CLIError(commandError: CommandError(code: .unknownCommand, message: "Unknown command: \(command)"))
        }
    }

    public static func parseLocation(_ args: [String]) throws -> (latitude: Double, longitude: Double, query: String?) {
        guard args.count >= 2, let latitude = Double(args[0]), let longitude = Double(args[1]) else {
            throw CLIError(commandError: CommandError(code: .usage, message: "usage: cosmokit location <lat> <lon> [name|udid]"))
        }
        return (latitude, longitude, args.count > 2 ? args[2] : nil)
    }

    public static func parseDuration(_ raw: String?) throws -> Double? {
        guard let raw else { return nil }
        guard let duration = Double(raw), duration > 0 else {
            throw CLIError(commandError: CommandError(code: .usage, message: "usage: cosmokit record --duration <seconds>"))
        }
        return duration
    }

    public static func parseInstalledApps(_ raw: String) throws -> [InstalledApp] {
        let object = try PropertyListSerialization.propertyList(from: Data(raw.utf8), format: nil)
        guard let dictionary = object as? [String: Any] else { return [] }
        return dictionary.values.compactMap { $0 as? [String: Any] }.compactMap { entry in
            let bundleID = (entry["CFBundleIdentifier"] as? String) ?? ""
            guard !bundleID.isEmpty else { return nil }
            let name = (entry["CFBundleDisplayName"] as? String) ?? (entry["CFBundleName"] as? String) ?? bundleID
            let path = (entry["Bundle"] as? String) ?? (entry["Path"] as? String) ?? ""
            let type = (entry["ApplicationType"] as? String) ?? ""
            return InstalledApp(bundleID: bundleID, name: name, path: path, type: type)
        }.sorted { $0.bundleID < $1.bundleID }
    }

    private static func parseStatusBar(_ args: [String]) throws -> (overrides: [String: String], device: String?) {
        let supported = Set(["time", "dataNetwork", "wifiMode", "wifiBars", "cellularMode", "cellularBars", "operatorName", "batteryState", "batteryLevel"])
        var overrides: [String: String] = [:]
        var device: String?
        var index = 0
        while index < args.count {
            guard args[index].hasPrefix("--") else { device = args[index]; index += 1; continue }
            let flag = String(args[index].dropFirst(2))
            guard supported.contains(flag), index + 1 < args.count else { throw CLIError(commandError: CommandError(code: .usage, message: "invalid statusbar flag or missing value: \(args[index])")) }
            let value = args[index + 1]
            if ["wifiBars", "cellularBars", "batteryLevel"].contains(flag) {
                guard Int(value) != nil else { throw CLIError(commandError: CommandError(code: .usage, message: "\(flag) must be an integer")) }
                if flag == "batteryLevel", let level = Int(value), !(0...100).contains(level) { throw CLIError(commandError: CommandError(code: .usage, message: "batteryLevel must be between 0 and 100")) }
            }
            overrides[flag] = value
            index += 2
        }
        return (overrides, device)
    }

    private static func parsePermission(_ args: [String]) throws -> (action: String, service: String, bundleID: String?, device: String?) {
        let actions = ["grant", "revoke", "reset"]
        let services = ["all", "calendar", "contacts-limited", "contacts", "location", "location-always", "photos-add", "photos", "media-library", "microphone", "motion", "reminders", "siri"]
        guard args.count >= 2, actions.contains(args[0]) else { throw CLIError(commandError: CommandError(code: .usage, message: "action must be one of: grant, revoke, reset")) }
        guard services.contains(args[1]) else { throw CLIError(commandError: CommandError(code: .usage, message: "service must be one of: \(services.joined(separator: ", "))")) }
        guard args[0] == "reset" || args.count >= 3 else { throw CLIError(commandError: CommandError(code: .usage, message: "grant and revoke require a bundle id")) }
        let bundleID = args.count > 2 ? args[2] : nil
        let device = args.count > 3 ? args[3] : nil
        return (args[0], args[1], bundleID, device)
    }

    private static func requiredBundle(_ args: [String], command: String) throws -> String {
        guard let bundle = args.first, !bundle.isEmpty else {
            throw CLIError(commandError: CommandError(code: .usage, message: "usage: cosmokit \(command) <bundle_id> [name|udid] (missing bundle_id)"))
        }
        return bundle
    }

    private static func resolveDevice(_ query: String?) throws -> Device {
        do {
            return try resolveDeviceForTesting(query)
        } catch {
            throw CLIError(commandError: CommandError(code: errorCode(for: error), message: error.localizedDescription))
        }
    }

    private static func devices() throws -> [Device] {
        do {
            return try Simctl.devices()
        } catch {
            throw CLIError(commandError: CommandError(code: .simctlFailed, message: error.localizedDescription))
        }
    }

    @discardableResult
    private static func runSimctl(_ arguments: [String]) throws -> String {
        do {
            return try runSimctlForTesting(arguments)
        } catch {
            throw CLIError(commandError: CommandError(code: .simctlFailed, message: error.localizedDescription))
        }
    }

    private static func usageText() -> String {
        """
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
          mcp                         Run as an MCP server over stdio (for AI agents)
          help                        Show this message

        OPTIONS
          --output <path>             Where to write a capture (default: ./)
          --json                      Emit machine-readable JSON on stdout
          --duration <seconds>        Recording duration (for record)

        EXAMPLES
          cosmokit capture --output ./screenshots
          cosmokit location -22.9068 -43.1729
          cosmokit open "myapp://item/42"
          cosmokit --json list
        """
    }

    private static func writeJSON<Payload: Encodable>(_ envelope: Envelope<Payload>) {
        do {
            writeJSONData(try encodeJSON(envelope))
        } catch {
            FileHandle.standardError.write(Data("cosmokit: could not encode JSON: \(error.localizedDescription)\n".utf8))
            exit(1)
        }
    }

    private static func encodeJSON<Payload: Encodable>(_ envelope: Envelope<Payload>) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(envelope)
    }

    private static func writeJSONData(_ data: Data) {
        print(String(decoding: data, as: UTF8.self))
    }

    private static func writeFailure(_ error: CommandError) {
        writeJSON(Envelope<EmptyPayload>(ok: false, error: error))
    }

    public static func errorCode(for error: Error) -> ErrorCode {
        if let commandError = error as? CLIError {
            return commandError.commandError.code
        }
        if let simctlError = error as? SimctlError {
            switch simctlError.kind {
            case .noBootedDevice:
                return .noSimulator
            case .noMatch:
                return .deviceNotFound
            case .commandFailed, .launchFailed:
                return .simctlFailed
            }
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

public struct InstalledApp: Codable {
    public let bundleID: String
    public let name: String
    public let path: String
    public let type: String

    public init(bundleID: String, name: String, path: String, type: String) {
        self.bundleID = bundleID
        self.name = name
        self.path = path
        self.type = type
    }
}

public struct AppsPayload: Codable {
    public let udid: String
    public let name: String
    public let apps: [InstalledApp]
    public init(udid: String, name: String, apps: [InstalledApp]) { self.udid = udid; self.name = name; self.apps = apps }
}

public struct InstallPayload: Codable {
    public let udid: String; public let name: String; public let path: String
    public init(udid: String, name: String, path: String) { self.udid = udid; self.name = name; self.path = path }
}

public struct UninstallPayload: Codable {
    public let udid: String; public let name: String; public let bundleID: String
    public init(udid: String, name: String, bundleID: String) { self.udid = udid; self.name = name; self.bundleID = bundleID }
}

public struct LaunchPayload: Codable {
    public let udid: String; public let name: String; public let bundleID: String; public let pid: Int?
    public init(udid: String, name: String, bundleID: String, pid: Int?) { self.udid = udid; self.name = name; self.bundleID = bundleID; self.pid = pid }
}

public struct TerminatePayload: Codable {
    public let udid: String; public let name: String; public let bundleID: String
    public init(udid: String, name: String, bundleID: String) { self.udid = udid; self.name = name; self.bundleID = bundleID }
}

public struct ContainerPayload: Codable {
    public let udid: String; public let name: String; public let bundleID: String; public let kind: String; public let path: String
    public init(udid: String, name: String, bundleID: String, kind: String, path: String) { self.udid = udid; self.name = name; self.bundleID = bundleID; self.kind = kind; self.path = path }
}

public struct AppearancePayload: Codable {
    public let udid: String; public let name: String; public let appearance: String
    public init(udid: String, name: String, appearance: String) { self.udid = udid; self.name = name; self.appearance = appearance }
}

public struct StatusBarPayload: Codable {
    public let udid: String; public let name: String; public let overrides: [String: String]
    public init(udid: String, name: String, overrides: [String: String]) { self.udid = udid; self.name = name; self.overrides = overrides }
}

public struct StatusBarClearPayload: Codable {
    public let udid: String; public let name: String
    public init(udid: String, name: String) { self.udid = udid; self.name = name }
}

public struct PermissionPayload: Codable {
    public let udid: String; public let name: String; public let action: String; public let service: String; public let bundleID: String?
    public init(udid: String, name: String, action: String, service: String, bundleID: String?) { self.udid = udid; self.name = name; self.action = action; self.service = service; self.bundleID = bundleID }
}

public struct BiometricEnrollPayload: Codable {
    public let udid: String; public let name: String; public let enrolled: Bool
    public init(udid: String, name: String, enrolled: Bool) { self.udid = udid; self.name = name; self.enrolled = enrolled }
}

public struct BiometricMatchPayload: Codable {
    public let udid: String; public let name: String; public let result: String
    public init(udid: String, name: String, result: String) { self.udid = udid; self.name = name; self.result = result }
}

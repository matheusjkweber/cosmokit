import Foundation

public enum Driver {
    public static var runProcessForTesting: (_ executable: String, _ arguments: [String]) throws -> String = { executable, arguments in
        let process = Process(); process.executableURL = URL(fileURLWithPath: executable); process.arguments = arguments
        let pipe = Pipe(); process.standardOutput = pipe; process.standardError = pipe
        try process.run(); process.waitUntilExit()
        let output = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        guard process.terminationStatus == 0 else { throw CLIError(commandError: CommandError(code: .driverUnavailable, message: output.trimmingCharacters(in: .whitespacesAndNewlines))) }
        return output
    }
    public static var httpForTesting: (_ method: String, _ url: URL, _ body: Data?) throws -> (Data, Int) = { method, url, body in
        var request = URLRequest(url: url); request.httpMethod = method; request.httpBody = body; request.timeoutInterval = 30
        if body != nil { request.setValue("application/json", forHTTPHeaderField: "Content-Type") }
        let semaphore = DispatchSemaphore(value: 0); var result: Result<(Data, Int), Error>!
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error { result = .failure(error) } else { result = .success((data ?? Data(), (response as? HTTPURLResponse)?.statusCode ?? 200)) }; semaphore.signal()
        }.resume(); semaphore.wait(); return try result.get()
    }

    public static var cacheDirectory: URL {
        let version = CLI.version
        let versionOutput = (try? runProcessForTesting("/usr/bin/xcodebuild", ["-version"])) ?? "unknown"
        let build = versionOutput.split(separator: "\n").first(where: { $0.contains("Build version") })?.replacingOccurrences(of: "Build version ", with: "") ?? "unknown"
        let safe = build.replacingOccurrences(of: " ", with: "-")
        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Caches/cosmokit/driver/\(version)-\(safe)")
    }

    public static func ensureBuilt() throws {
        let cache = cacheDirectory; let xctestrun = try xctestrunFile(in: cache)
        if xctestrun != nil { return }
        try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Driver")
        _ = try runProcessForTesting("/usr/bin/xcodebuild", ["build-for-testing", "-project", root.appendingPathComponent("CosmoKitAgentDriver.xcodeproj").path, "-scheme", "AgentDriver", "-destination", "platform=iOS Simulator", "-derivedDataPath", cache.path])
    }

    public static func start(device: String?, port: Int = 8877) throws -> DriverStatusPayload {
        let deviceID = try resolveDevice(device); if let current = try? statusCall(deviceID, port: port), current.running { return current }
        try ensureBuilt(); let cache = cacheDirectory; let xctestrun = try requireXctestrun(in: cache)
        let log = cache.appendingPathComponent("driver.log"); let pidFile = cache.appendingPathComponent("driver-\(deviceID).json")
        FileManager.default.createFile(atPath: log.path, contents: nil)
        let process = Process(); process.executableURL = URL(fileURLWithPath: "/usr/bin/xcodebuild"); process.arguments = ["test-without-building", "-xctestrun", xctestrun.path, "-destination", "id=\(deviceID)", "TEST_RUNNER_COSMOKIT_DRIVER_PORT=\(port)"]; process.standardOutput = try FileHandle(forWritingTo: log); process.standardError = process.standardOutput; try process.run()
        try JSONSerialization.data(withJSONObject: ["pid": process.processIdentifier, "port": port]).write(to: pidFile)
        for _ in 0..<90 { if let status = try? statusCall(deviceID, port: port), status.running { return status }; Thread.sleep(forTimeInterval: 1) }
        throw driverError("driver did not become reachable; inspect \(log.path)")
    }

    public static func stop(device: String?) throws -> DriverActionPayload { let id = try resolveDevice(device); let current = status(device: id); if let port = current.port { _ = try? call("/quit", method: "POST", json: [:], port: port) }; if let pid = current.pid { kill(pid_t(pid), SIGTERM) }; return DriverActionPayload(message: "Stopped driver on \(id)") }
    public static func status(device: String?) -> DriverStatusPayload { guard let id = try? resolveDevice(device), !id.isEmpty else { return DriverStatusPayload(running: false) }; return (try? statusCall(id, port: 8877)) ?? DriverStatusPayload(running: false) }
    public static func call(_ path: String, method: String = "GET", json: [String: Any]? = nil, port: Int = 8877) throws -> Data { let body = json.flatMap { try? JSONSerialization.data(withJSONObject: $0) }; var urlString = "http://127.0.0.1:\(port)\(path)"; if method == "GET", let json, !json.isEmpty { let query = json.keys.sorted().compactMap { key in json[key].map { "\(key)=\(String(describing: $0).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" } }.joined(separator: "&"); urlString += "?\(query)" }; let url = URL(string: urlString)!; do { let (data, code) = try httpForTesting(method, url, method == "GET" ? nil : body); if code >= 400 { throw driverError(String(decoding: data, as: UTF8.self)) }; return data } catch let error as CLIError { throw error } catch { throw driverError("driver unavailable; run: cosmokit agent start (\(error.localizedDescription))") } }

    private static func resolveDevice(_ query: String?) throws -> String { if let query, !query.isEmpty { return (try? Simctl.resolveDevice(query).udid) ?? query }; return try Simctl.resolveDevice(nil).udid }
    private static func statusCall(_ device: String, port: Int) throws -> DriverStatusPayload { let data = try call("/status", port: port); let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]; return DriverStatusPayload(running: object?["ok"] as? Bool ?? true, port: port, pid: pid(for: device), app: object?["app"] as? String) }
    private static func pid(for device: String) -> Int? { let file = cacheDirectory.appendingPathComponent("driver-\(device).json"); guard let data = try? Data(contentsOf: file), let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }; return object["pid"] as? Int }
    private static func xctestrunFile(in directory: URL) throws -> URL? { let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: [.isRegularFileKey]); return enumerator?.compactMap { $0 as? URL }.first { $0.pathExtension == "xctestrun" } }
    private static func requireXctestrun(in directory: URL) throws -> URL { guard let file = try xctestrunFile(in: directory) else { throw driverError("driver build did not produce an .xctestrun file") }; return file }
    private static func driverError(_ message: String) -> CLIError { CLIError(commandError: CommandError(code: .driverUnavailable, message: message)) }
}

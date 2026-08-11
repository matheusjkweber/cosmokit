//
//  MCPServer.swift
//  cosmokit CLI
//
//  Minimal newline-delimited JSON-RPC transport for agent clients.
//

import Foundation

public enum MCPServer {
    /// Handles one JSON-RPC message. Notifications receive no response.
    public static func handle(line: String) -> String? {
        guard let data = line.data(using: .utf8),
              let object = try? JSONSerialization.jsonObject(with: data) else {
            return response(id: NSNull(), error: [-32700, "Parse error"])
        }
        guard let request = object as? [String: Any] else {
            return response(id: NSNull(), error: [-32600, "Invalid Request"])
        }

        guard let method = request["method"] as? String else {
            return response(id: request["id"] ?? NSNull(), error: [-32600, "Invalid Request"])
        }

        guard request["id"] != nil else {
            return nil
        }

        switch method {
        case "initialize":
            guard request["params"] == nil || request["params"] is [String: Any] else {
                return response(id: request["id"] ?? NSNull(), error: [-32602, "Invalid params"])
            }
            let params = request["params"] as? [String: Any]
            let requestedVersion = params?["protocolVersion"] as? String
            let supportedVersions = ["2024-11-05", "2025-03-26", "2025-06-18"]
            let protocolVersion = supportedVersions.contains(requestedVersion ?? "") ? requestedVersion! : "2025-06-18"
            return response(id: request["id"] ?? NSNull(), result: [
                "protocolVersion": protocolVersion,
                "capabilities": ["tools": [:]],
                "serverInfo": ["name": "cosmokit", "version": CLI.version]
            ])

        case "tools/list":
            guard request["params"] == nil || request["params"] is [String: Any] else {
                return response(id: request["id"] ?? NSNull(), error: [-32602, "Invalid params"])
            }
            return response(id: request["id"] ?? NSNull(), result: ["tools": tools()])

        default:
            return response(id: request["id"] ?? NSNull(), error: [-32601, "Method not found"])
        }
    }

    /// Reads newline-delimited requests until stdin reaches EOF.
    public static func serve() {
        while let line = readLine(strippingNewline: true) {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            guard let result = handle(line: line) else { continue }
            FileHandle.standardOutput.write(Data((result + "\n").utf8))
            try? FileHandle.standardOutput.synchronize()
        }
    }

    private static func response(id: Any, result: Any? = nil, error: [Any]? = nil) -> String {
        var response: [String: Any] = ["jsonrpc": "2.0", "id": id]
        if let result {
            response["result"] = result
        } else if let error {
            response["error"] = ["code": error[0], "message": error[1]]
        }
        guard let data = try? JSONSerialization.data(withJSONObject: response, options: []) else {
            return "{\"jsonrpc\":\"2.0\",\"id\":null,\"error\":{\"code\":-32603,\"message\":\"Internal error\"}}"
        }
        return String(decoding: data, as: UTF8.self)
    }

    private static func tools() -> [[String: Any]] {
        let device = [
            "type": "string",
            "description": "UDID, exact name, or partial name; omit to use the booted simulator"
        ]
        return [
            tool("list_simulators", "List available iOS Simulators, sorted by name. Takes no arguments.", properties: [:], required: []),
            tool("boot_simulator", "Boot a simulator by UDID, exact name, or partial name; omit device to boot the first available shutdown simulator.", properties: ["device": device], required: []),
            tool("shutdown_simulator", "Shut down a simulator by UDID, exact name, or partial name; omit device to use the booted simulator.", properties: ["device": device], required: []),
            tool("capture_screenshot", "Capture a PNG screenshot from a simulator; omit device to use the booted simulator and output to use the current directory.", properties: ["device": device, "output": ["type": "string", "description": "Directory where the timestamped PNG should be written"]], required: []),
            tool("record_video", "Record simulator video for a fixed number of seconds; omit device to use the booted simulator and output to use the current directory.", properties: ["device": device, "output": ["type": "string", "description": "Directory where the timestamped MP4 should be written"], "duration": ["type": "number", "description": "Number of seconds to record"]], required: ["duration"]),
            tool("set_location", "Set a simulator's GPS location using latitude and longitude; omit device to use the booted simulator.", properties: ["device": device, "latitude": ["type": "number", "description": "Latitude in decimal degrees"], "longitude": ["type": "number", "description": "Longitude in decimal degrees"]], required: ["latitude", "longitude"]),
            tool("open_url", "Open a deep link or URL in a simulator; omit device to use the booted simulator.", properties: ["device": device, "url": ["type": "string", "description": "URL or deep link to open"]], required: ["url"]),
            tool("erase_simulator", "Erase a simulator back to a fresh install by UDID, exact name, or partial name; omit device to use the booted simulator.", properties: ["device": device], required: [])
        ]
    }

    private static func tool(_ name: String, _ description: String, properties: [String: Any], required: [String]) -> [String: Any] {
        [
            "name": name,
            "description": description,
            "inputSchema": [
                "type": "object",
                "properties": properties,
                "required": required
            ]
        ]
    }
}

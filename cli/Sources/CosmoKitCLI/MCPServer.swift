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
              let object = try? JSONSerialization.jsonObject(with: data),
              let request = object as? [String: Any] else {
            return response(id: NSNull(), error: [-32700, "Parse error"])
        }

        guard let method = request["method"] as? String else {
            return response(id: request["id"] ?? NSNull(), error: [-32600, "Invalid Request"])
        }

        guard request["id"] != nil else {
            return nil
        }

        switch method {
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
}

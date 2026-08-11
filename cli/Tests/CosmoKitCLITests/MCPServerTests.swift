import XCTest
@testable import CosmoKitCLI

final class MCPServerTests: XCTestCase {
    private let toolNames: Set<String> = [
        "list_simulators", "boot_simulator", "shutdown_simulator", "capture_screenshot",
        "record_video", "set_location", "open_url", "erase_simulator"
    ]

    func testInitializeNegotiatesCurrentVersionAndServerInfo() throws {
        let response = try object(for: #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18"}}"#)
        XCTAssertEqual(protocolVersion(response), "2025-06-18")
        XCTAssertEqual(serverName(response), "cosmokit")
    }

    func testInitializeEchoesOlderSupportedVersion() throws {
        let response = try object(for: #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05"}}"#)
        XCTAssertEqual(protocolVersion(response), "2024-11-05")
    }

    func testInitializeFallsBackForUnknownVersion() throws {
        let response = try object(for: #"{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2099-01-01"}}"#)
        XCTAssertEqual(protocolVersion(response), "2025-06-18")
    }

    func testInitializeAdvertisesToolsCapability() throws {
        let response = try object(for: #"{"jsonrpc":"2.0","id":1,"method":"initialize"}"#)
        let result = response["result"] as! [String: Any]
        let capabilities = result["capabilities"] as! [String: Any]
        XCTAssertNotNil(capabilities["tools"] as? [String: Any])
    }

    func testNotificationsReceiveNoResponse() {
        XCTAssertNil(MCPServer.handle(line: #"{"jsonrpc":"2.0","method":"notifications/initialized"}"#))
        XCTAssertNil(MCPServer.handle(line: #"{"jsonrpc":"2.0","method":"anything"}"#))
    }

    func testToolsListAdvertisesEightToolsAndSchemas() throws {
        let response = try object(for: #"{"jsonrpc":"2.0","id":1,"method":"tools/list"}"#)
        let result = response["result"] as! [String: Any]
        let tools = result["tools"] as! [[String: Any]]
        XCTAssertEqual(tools.count, 8)
        XCTAssertEqual(Set(tools.compactMap { $0["name"] as? String }), toolNames)
        for tool in tools {
            let schema = tool["inputSchema"] as! [String: Any]
            XCTAssertEqual(schema["type"] as? String, "object")
            XCTAssertNotNil(schema["properties"] as? [String: Any])
        }
        let record = try tool(named: "record_video", in: tools)
        XCTAssertEqual(record["required"] as? [String], ["duration"])
        let capture = try tool(named: "capture_screenshot", in: tools)
        XCTAssertEqual(capture["required"] as? [String], [])
        let location = try tool(named: "set_location", in: tools)
        XCTAssertEqual(Set(location["required"] as? [String] ?? []), ["latitude", "longitude"])
    }

    func testUnknownMethodEchoesIdAndErrorCode() throws {
        let response = try object(for: #"{"jsonrpc":"2.0","id":"abc","method":"nope"}"#)
        XCTAssertEqual(response["id"] as? String, "abc")
        XCTAssertEqual(errorCode(response), -32601)
    }

    func testMalformedAndInvalidRequests() throws {
        let parse = try object(for: "not json")
        XCTAssertTrue(parse["id"] is NSNull)
        XCTAssertEqual(errorCode(parse), -32700)
        XCTAssertEqual(errorCode(try object(for: "[]")), -32600)
        XCTAssertEqual(errorCode(try object(for: #"{"jsonrpc":"2.0","id":1}"#)), -32600)
    }

    func testEveryResponseIsJSONRPC() throws {
        for line in [
            #"{"jsonrpc":"2.0","id":1,"method":"initialize"}"#,
            #"{"jsonrpc":"2.0","id":2,"method":"tools/list"}"#,
            #"{"jsonrpc":"2.0","id":3,"method":"unknown"}"#,
            "not json"
        ] {
            let response = try object(for: line)
            XCTAssertEqual(response["jsonrpc"] as? String, "2.0")
        }
    }

    private func object(for line: String) throws -> [String: Any] {
        guard let response = MCPServer.handle(line: line),
              let data = response.data(using: .utf8),
              let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "MCPServerTests", code: 1)
        }
        return object
    }

    private func protocolVersion(_ response: [String: Any]) -> String? {
        (response["result"] as? [String: Any])?["protocolVersion"] as? String
    }

    private func serverName(_ response: [String: Any]) -> String? {
        ((response["result"] as? [String: Any])?["serverInfo"] as? [String: Any])?["name"] as? String
    }

    private func errorCode(_ response: [String: Any]) -> Int? {
        (response["error"] as? [String: Any])?["code"] as? Int
    }

    private func tool(named name: String, in tools: [[String: Any]]) throws -> [String: Any] {
        guard let tool = tools.first(where: { $0["name"] as? String == name }),
              let schema = tool["inputSchema"] as? [String: Any] else {
            throw NSError(domain: "MCPServerTests", code: 2)
        }
        return schema
    }
}

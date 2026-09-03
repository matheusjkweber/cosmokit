import Foundation
import Network
import XCTest

final class AgentDriverTests: XCTestCase {
    private var listener: NWListener?
    private let app = XCUIApplication(bundleIdentifier: "apps.mjkweber.CosmoKitAgentHost")
    private var refs: [Int: XCUIElement] = [:]
    private var nextRef = 1

    func testServe() {
        continueAfterFailure = true
        app.launch()
        let rawPort = ProcessInfo.processInfo.environment["TEST_RUNNER_COSMOKIT_DRIVER_PORT"] ?? ProcessInfo.processInfo.environment["COSMOKIT_DRIVER_PORT"] ?? "8877"
        let port = NWEndpoint.Port(rawValue: UInt16(rawPort) ?? 8877)!
        listener = try? NWListener(using: .tcp, on: port)
        listener?.newConnectionHandler = { [weak self] connection in self?.receive(connection) }
        listener?.start(queue: .main)
        RunLoop.main.run()
    }

    private func receive(_ connection: NWConnection) {
        connection.start(queue: .main)
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1_000_000) { [weak self] data, _, _, _ in
            guard let self, let data, let request = String(data: data, encoding: .utf8) else { connection.cancel(); return }
            let lines = request.components(separatedBy: "\r\n")
            let first = lines.first?.split(separator: " ") ?? []
            let method = first.first.map(String.init) ?? "GET"
            let path = first.dropFirst().first.map(String.init) ?? "/"
            let response = self.handle(method: method, path: path)
            let bytes = Data(response.utf8)
            let header = Data("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: \(bytes.count)\r\nConnection: close\r\n\r\n".utf8)
            connection.send(content: header + bytes, completion: .contentProcessed { _ in connection.cancel() })
        }
    }

    private func handle(method: String, path: String) -> String {
        if path == "/quit" { DispatchQueue.main.async { self.listener?.cancel(); CFRunLoopStop(CFRunLoopGetMain()) }; return "{\"ok\":true}" }
        if path == "/status" { return encoded(["ok": true, "driverVersion": "0.2.0", "udid": "", "app": "apps.mjkweber.CosmoKitAgentHost"]) }
        if path == "/tree" { return tree() }
        if path == "/screenshot" { return "{\"ok\":true}" }
        if ["/app", "/tap", "/press", "/swipe", "/type", "/button", "/alert"].contains(path) { return "{\"ok\":true}" }
        return "{\"ok\":false,\"error\":{\"code\":\"unsupported\",\"message\":\"unknown endpoint\"}}"
    }

    private func tree() -> String {
        nextRef = 1; refs.removeAll()
        let window = app.windows.firstMatch
        let elements = [window] + app.descendants(matching: .any).allElementsBoundByIndex
        let values: [[String: Any]] = elements.map { element in
            let ref = nextRef; nextRef += 1; refs[ref] = element; let frame = element.frame
            return ["ref": ref, "type": typeName(element.elementType), "id": element.identifier, "label": element.label, "value": element.value ?? "", "placeholder": "", "enabled": element.isEnabled, "selected": element.isSelected, "focused": element.isHittable, "frame": ["x": frame.origin.x, "y": frame.origin.y, "width": frame.size.width, "height": frame.size.height], "children": []]
        }
        return encoded(["app": "apps.mjkweber.CosmoKitAgentHost", "elements": values, "truncated": false])
    }

    private func typeName(_ type: XCUIElement.ElementType) -> String {
        switch type {
        case .application: return "application"; case .group: return "group"; case .window: return "window"; case .button: return "button"; case .staticText: return "staticText"; case .textField: return "textField"; case .secureTextField: return "secureTextField"; case .cell: return "cell"; case .image: return "image"; case .navigationBar: return "navigationBar"; case .tabBar: return "tabBar"; case .tab: return "tab"; case .switch: return "switch"; case .slider: return "slider"; case .scrollView: return "scrollView"; case .table: return "table"; case .collectionView: return "collectionView"; default: return "element"
        }
    }

    private func encoded(_ object: [String: Any]) -> String { String(data: (try? JSONSerialization.data(withJSONObject: object)) ?? Data("{}".utf8), encoding: .utf8) ?? "{}" }
}

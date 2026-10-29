import XCTest
import Capacitor
@testable import Plugin

class PluginTests: XCTestCase {
    private var directory: URL!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: directory)
    }

    private func invoke(_ method: String, options: [String: Any], expectError: Bool = false) -> [[String: Any]] {
        let finished = expectation(description: method)
        var results: [[String: Any]] = []
        var invocation: CAPPluginCall!
        invocation = CAPPluginCall(callbackId: UUID().uuidString, methodName: method, options: options, success: { result, call in
            guard let data = result?.data, let call = call else {
                XCTFail("Missing callback data")
                return
            }
            results.append(data)
            let completed = data["completed"] as? Bool == true
            XCTAssertEqual(call.keepAlive, !completed)
            if completed {
                XCTAssertFalse(expectError)
                finished.fulfill()
            }
        }, error: { _ in
            XCTAssertTrue(expectError)
            XCTAssertFalse(invocation.keepAlive)
            finished.fulfill()
        })
        let plugin = ZipPlugin()
        if method == "zip" {
            plugin.zip(invocation)
        } else {
            plugin.unZip(invocation)
        }
        wait(for: [finished], timeout: 10)
        return results
    }

    func testProgressKeepsCallbackUntilCompletion() throws {
        let source = directory.appendingPathComponent("source")
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        for index in 0..<4 {
            try Data("file-\(index)".utf8).write(to: source.appendingPathComponent("\(index).txt"))
        }
        let archive = directory.appendingPathComponent("archive.zip")
        let zipped = invoke("zip", options: ["source": source.path, "destination": archive.path])
        XCTAssertTrue(zipped.contains { (1..<100).contains($0["progress"] as? Int ?? 0) })
        let destination = directory.appendingPathComponent("output")
        let extracted = invoke("unZip", options: ["source": archive.path, "destination": destination.path])
        XCTAssertTrue(extracted.contains { (1..<100).contains($0["progress"] as? Int ?? 0) })
        XCTAssertEqual(extracted.last?["path"] as? String, destination.path)
    }

    func testRepeatedExtractionOverwritesExistingFiles() throws {
        let source = directory.appendingPathComponent("source")
        try FileManager.default.createDirectory(at: source, withIntermediateDirectories: true)
        try Data("new database".utf8).write(to: source.appendingPathComponent("cache.db"))
        let archive = directory.appendingPathComponent("archive.zip")
        _ = invoke("zip", options: ["source": source.path, "destination": archive.path, "overwrite": false])
        let destination = directory.appendingPathComponent("output")
        for _ in 0..<2 {
            _ = invoke("unZip", options: ["source": archive.absoluteString, "destination": destination.absoluteString, "overwrite": true])
            let database = destination.appendingPathComponent("cache.db")
            XCTAssertEqual(try Data(contentsOf: database), Data("new database".utf8))
            try Data("old database".utf8).write(to: database)
        }
    }

    func testInvalidArchiveReleasesCallbackWithoutReplacingDatabase() throws {
        let archive = directory.appendingPathComponent("invalid.zip")
        try Data("not a zip".utf8).write(to: archive)
        let database = directory.appendingPathComponent("cache.db")
        try Data("existing database".utf8).write(to: database)
        _ = invoke("unZip", options: ["source": archive.path, "destination": directory.path], expectError: true)
        XCTAssertEqual(try Data(contentsOf: database), Data("existing database".utf8))
    }
}

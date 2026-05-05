// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
import Foundation
@testable import BareSwiftCLI

@Suite("Scaffolder")
struct ScaffolderTests {
    @Test("creates all expected files for a swift-greet scaffold")
    func createsExpectedFiles() throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("bare-swift-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let outputURL = tempRoot.appendingPathComponent("swift-greet")
        let scaffolder = Scaffolder(
            packageName: "swift-greet",
            moduleName: "Greet",
            sourceCrate: nil,
            outputDir: outputURL
        )
        try scaffolder.scaffold()

        let expected = [
            "Package.swift",
            "Sources/Greet/Greet.swift",
            "Sources/Greet/Documentation.docc/Greet.md",
            "Tests/GreetTests/GreetTests.swift",
            "Tests/Vectors/.gitkeep",
            "README.md",
            "LICENSE",
            "NOTICE",
            "CHANGELOG.md",
            "MAINTAINERS.md",
            "SECURITY.md",
            ".gitignore",
            ".github/workflows/ci.yml",
            ".github/workflows/docs.yml",
            ".github/workflows/release.yml",
            ".github/PULL_REQUEST_TEMPLATE.md",
            ".github/ISSUE_TEMPLATE/bug_report.md",
            ".github/ISSUE_TEMPLATE/feature_request.md",
        ]
        for relative in expected {
            let url = outputURL.appendingPathComponent(relative)
            #expect(FileManager.default.fileExists(atPath: url.path), "missing: \(relative)")
        }
    }

    @Test("Package.swift contains correct package + module names")
    func packageSwiftContents() throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("bare-swift-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let outputURL = tempRoot.appendingPathComponent("swift-uuid")
        let scaffolder = Scaffolder(
            packageName: "swift-uuid",
            moduleName: "UUID",
            sourceCrate: "uuid",
            outputDir: outputURL
        )
        try scaffolder.scaffold()

        let packageSwift = try String(
            contentsOf: outputURL.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        #expect(packageSwift.contains("name: \"swift-uuid\""))
        #expect(packageSwift.contains(".library(name: \"UUID\""))
        #expect(packageSwift.contains(".target(name: \"UUID\")"))
        #expect(packageSwift.contains("swift-docc-plugin"))

        let docsYml = try String(
            contentsOf: outputURL.appendingPathComponent(".github/workflows/docs.yml"),
            encoding: .utf8
        )
        #expect(docsYml.contains("target: UUID"))
        #expect(!docsYml.contains("{{"))
    }

    @Test("NOTICE includes source crate when provided")
    func noticeIncludesSource() throws {
        let tempRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent("bare-swift-test-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: tempRoot) }

        let outputURL = tempRoot.appendingPathComponent("swift-uuid")
        let scaffolder = Scaffolder(
            packageName: "swift-uuid",
            moduleName: "UUID",
            sourceCrate: "uuid",
            outputDir: outputURL
        )
        try scaffolder.scaffold()

        let notice = try String(
            contentsOf: outputURL.appendingPathComponent("NOTICE"),
            encoding: .utf8
        )
        #expect(notice.contains("uuid"))
        #expect(notice.contains("crates.io/crates/uuid"))
    }
}

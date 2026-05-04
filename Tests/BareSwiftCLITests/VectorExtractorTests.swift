// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
import Foundation
@testable import BareSwiftCLI

@Suite("VectorExtractor.extract")
struct VectorExtractorTests {
    @Test("copies a single explicit file")
    func singleFile() throws {
        let (crate, output) = try makeFixture(files: ["tests/data/foo.txt": "hello"])
        defer { try? FileManager.default.removeItem(at: crate.deletingLastPathComponent()) }

        let copied = try VectorExtractor.extract(
            entries: ["tests/data/foo.txt"],
            from: crate,
            to: output
        )
        #expect(copied == 1)
        let dest = output.appendingPathComponent("tests/data/foo.txt")
        #expect(FileManager.default.fileExists(atPath: dest.path))
        #expect(try String(contentsOf: dest, encoding: .utf8) == "hello")
    }

    @Test("expands a single-star glob in a fixed directory")
    func singleStarGlob() throws {
        let (crate, output) = try makeFixture(files: [
            "tests/data/a.txt": "A",
            "tests/data/b.txt": "B",
            "tests/data/sub/c.txt": "C",
        ])
        defer { try? FileManager.default.removeItem(at: crate.deletingLastPathComponent()) }

        let copied = try VectorExtractor.extract(
            entries: ["tests/data/*.txt"],
            from: crate,
            to: output
        )
        #expect(copied == 2)
        #expect(FileManager.default.fileExists(atPath: output.appendingPathComponent("tests/data/a.txt").path))
        #expect(FileManager.default.fileExists(atPath: output.appendingPathComponent("tests/data/b.txt").path))
        #expect(!FileManager.default.fileExists(atPath: output.appendingPathComponent("tests/data/sub/c.txt").path))
    }

    @Test("ignores entries that match nothing (returns count for matched ones)")
    func unmatched() throws {
        let (crate, output) = try makeFixture(files: ["tests/data/foo.txt": "hello"])
        defer { try? FileManager.default.removeItem(at: crate.deletingLastPathComponent()) }

        let copied = try VectorExtractor.extract(
            entries: ["tests/missing/*.txt", "tests/data/foo.txt"],
            from: crate,
            to: output
        )
        #expect(copied == 1)
    }

    private func makeFixture(files: [String: String]) throws -> (URL, URL) {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ve-test-\(UUID().uuidString)")
        let crate = root.appendingPathComponent("crate")
        let output = root.appendingPathComponent("out")
        for (rel, contents) in files {
            let url = crate.appendingPathComponent(rel)
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try contents.write(to: url, atomically: true, encoding: .utf8)
        }
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        return (crate, output)
    }
}

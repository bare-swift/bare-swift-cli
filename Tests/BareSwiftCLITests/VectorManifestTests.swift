// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import BareSwiftCLI

@Suite("VectorManifest.parse")
struct VectorManifestTests {
    @Test("parses simple paths")
    func simple() throws {
        let entries = try VectorManifest.parse(string: """
        tests/data/foo.txt
        tests/data/bar.bin
        """)
        #expect(entries == ["tests/data/foo.txt", "tests/data/bar.bin"])
    }

    @Test("ignores comments and blank lines")
    func commentsAndBlanks() throws {
        let entries = try VectorManifest.parse(string: """
        # leading comment
        tests/data/foo.txt

          # indented comment

        tests/data/bar.bin
        """)
        #expect(entries == ["tests/data/foo.txt", "tests/data/bar.bin"])
    }

    @Test("trims surrounding whitespace")
    func trims() throws {
        let entries = try VectorManifest.parse(string: "  tests/data/foo.txt  \n  tests/data/bar.bin\t")
        #expect(entries == ["tests/data/foo.txt", "tests/data/bar.bin"])
    }

    @Test("preserves glob characters")
    func globs() throws {
        let entries = try VectorManifest.parse(string: """
        tests/data/*.txt
        tests/fixtures/**/*.bin
        """)
        #expect(entries == ["tests/data/*.txt", "tests/fixtures/**/*.bin"])
    }
}

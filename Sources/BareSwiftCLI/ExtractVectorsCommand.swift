// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import ArgumentParser
import Foundation

struct ExtractVectorsCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "extract-vectors",
        abstract: "Copy test fixtures from a source Rust crate into Tests/Vectors/."
    )

    @Option(name: .long, help: "Path to the source Rust crate root (containing Cargo.toml).")
    var crate: String

    @Option(name: .long, help: "Manifest file listing fixtures to copy. One path or glob per line; # comments allowed.")
    var manifest: String

    @Option(name: .long, help: "Output directory.")
    var output: String = "Tests/Vectors"

    func run() throws {
        let crateURL = URL(fileURLWithPath: crate)
        let manifestURL = URL(fileURLWithPath: manifest)
        let outputURL = URL(fileURLWithPath: output)
        let entries = try VectorManifest.parse(contentsOf: manifestURL)
        let copied = try VectorExtractor.extract(entries: entries, from: crateURL, to: outputURL)
        print("Copied \(copied) file(s) into \(outputURL.path)")
    }
}

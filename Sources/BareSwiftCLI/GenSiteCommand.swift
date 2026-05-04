// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import ArgumentParser
import Foundation

struct GenSiteCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "gen-site",
        abstract: "Render the umbrella site index from packages/index.json."
    )

    @Option(name: .long, help: "Path to the umbrella repo root.")
    var umbrella: String = "."

    func run() throws {
        let umbrellaURL = URL(fileURLWithPath: umbrella)
        let indexURL = umbrellaURL.appendingPathComponent("packages/index.json")
        let index = try PackageIndex.load(from: indexURL)
        let html = SiteGenerator.renderIndex(index)
        let outURL = umbrellaURL.appendingPathComponent("site/index.html")
        try FileManager.default.createDirectory(at: outURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try html.write(to: outURL, atomically: true, encoding: .utf8)
        print("Wrote \(outURL.path) (\(index.packages.count) package(s))")
    }
}

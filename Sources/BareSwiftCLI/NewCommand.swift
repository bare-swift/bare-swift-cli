// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import ArgumentParser
import Foundation

struct NewCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "new",
        abstract: "Scaffold a new bare-swift package."
    )

    @Argument(help: "Package name (e.g., swift-uuid).")
    var name: String

    @Option(name: .long, help: "Module name. Defaults to name with 'swift-' stripped, kebab→PascalCase.")
    var module: String?

    @Option(name: .long, help: "Source Rust crate name (for NOTICE / README links). Optional.")
    var source: String?

    @Option(name: .long, help: "Output directory. Defaults to current directory.")
    var output: String = "."

    func run() throws {
        let moduleName = module ?? Self.deriveModuleName(from: name)
        let outputURL = URL(fileURLWithPath: output).appendingPathComponent(name)
        let scaffolder = Scaffolder(
            packageName: name,
            moduleName: moduleName,
            sourceCrate: source,
            outputDir: outputURL
        )
        try scaffolder.scaffold()
        print("Scaffolded \(name) (module \(moduleName)) at \(outputURL.path)")
    }

    static func deriveModuleName(from packageName: String) -> String {
        let stripped: String
        if packageName.hasPrefix("swift-") {
            stripped = String(packageName.dropFirst("swift-".count))
        } else {
            stripped = packageName
        }
        return stripped
            .split(separator: "-")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined()
    }
}

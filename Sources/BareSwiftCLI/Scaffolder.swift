// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Foundation

struct Scaffolder {
    let packageName: String
    let moduleName: String
    let sourceCrate: String?   // e.g., "uuid", "twox-hash"
    let outputDir: URL

    func scaffold() throws {
        try createDirectories()
        try writeRendered("Package.swift.tmpl", to: "Package.swift")
        try writeRendered("Module.swift.tmpl", to: "Sources/\(moduleName)/\(moduleName).swift")
        try writeRendered("Documentation.md.tmpl", to: "Sources/\(moduleName)/Documentation.docc/\(moduleName).md")
        try writeRendered("ModuleTests.swift.tmpl", to: "Tests/\(moduleName)Tests/\(moduleName)Tests.swift")
        try writeRaw("", to: "Tests/Vectors/.gitkeep")
        try writeRendered("README.md.tmpl", to: "README.md")
        try writeRendered("NOTICE.tmpl", to: "NOTICE")
        try writeRendered("CHANGELOG.md.tmpl", to: "CHANGELOG.md")
        try writeRendered("MAINTAINERS.md.tmpl", to: "MAINTAINERS.md")
        try writeRendered("SECURITY.md.tmpl", to: "SECURITY.md")
        try writeResource("gitignore", to: ".gitignore")
        try writeResource("ci.yml", to: ".github/workflows/ci.yml")
        try writeRendered("docs.yml.tmpl", to: ".github/workflows/docs.yml")
        try writeResource("release.yml", to: ".github/workflows/release.yml")
        try writeResource("PULL_REQUEST_TEMPLATE.md", to: ".github/PULL_REQUEST_TEMPLATE.md")
        try writeResource("bug_report.md", to: ".github/ISSUE_TEMPLATE/bug_report.md")
        try writeResource("feature_request.md", to: ".github/ISSUE_TEMPLATE/feature_request.md")
        try writeLicense()
    }

    private func createDirectories() throws {
        let dirs = [
            "Sources/\(moduleName)",
            "Sources/\(moduleName)/Documentation.docc",
            "Tests/\(moduleName)Tests",
            "Tests/Vectors",
            ".github/workflows",
            ".github/ISSUE_TEMPLATE",
        ]
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
        for sub in dirs {
            try FileManager.default.createDirectory(
                at: outputDir.appendingPathComponent(sub),
                withIntermediateDirectories: true
            )
        }
    }

    private func writeRendered(_ templateName: String, to relativePath: String) throws {
        let template = try loadResource(templateName)
        let rendered = TemplateRenderer.render(template: template, with: replacements())
        try writeRaw(rendered, to: relativePath)
    }

    private func writeResource(_ resourceName: String, to relativePath: String) throws {
        let content = try loadResource(resourceName)
        try writeRaw(content, to: relativePath)
    }

    private func writeRaw(_ contents: String, to relativePath: String) throws {
        let url = outputDir.appendingPathComponent(relativePath)
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Writes the LICENSE file. Stored as a resource named "LICENSE.txt".
    private func writeLicense() throws {
        let licenseText = (try? loadResource("LICENSE.txt")) ?? ""
        try writeRaw(licenseText, to: "LICENSE")
    }

    private func loadResource(_ name: String) throws -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "templates") else {
            throw ScaffolderError.templateNotFound(name)
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func replacements() -> [String: String] {
        let year = Calendar(identifier: .gregorian).component(.year, from: Date())
        let crate = sourceCrate ?? "(none)"
        let crateURL: String
        let sourceNote: String
        if let sourceCrate {
            crateURL = "https://crates.io/crates/\(sourceCrate)"
            sourceNote = ""
        } else {
            crateURL = "(none)"
            sourceNote = " (No upstream Rust crate; this is a native bare-swift package.)"
        }
        return [
            "PACKAGE_NAME": packageName,
            "MODULE": moduleName,
            "YEAR": String(year),
            "SOURCE_CRATE": crate,
            "SOURCE_CRATE_URL": crateURL,
            "SOURCE_NOTE": sourceNote,
        ]
    }
}

enum ScaffolderError: Error, CustomStringConvertible {
    case templateNotFound(String)

    var description: String {
        switch self {
        case .templateNotFound(let name): "template not found: \(name)"
        }
    }
}

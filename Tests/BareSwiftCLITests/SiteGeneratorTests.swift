// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
import Foundation
@testable import BareSwiftCLI

@Suite("PackageIndex + SiteGenerator")
struct SiteGeneratorTests {
    @Test("decodes a populated index.json")
    func decodes() throws {
        let json = """
        {
          "packages": [
            {
              "name": "swift-greet",
              "module": "Greet",
              "tagline": "A friendly greeter.",
              "repo": "https://github.com/bare-swift/swift-greet",
              "version": "0.1.0",
              "source_crate": null,
              "tier": "demo"
            }
          ]
        }
        """
        let index = try PackageIndex.decode(from: Data(json.utf8))
        #expect(index.packages.count == 1)
        #expect(index.packages[0].name == "swift-greet")
        #expect(index.packages[0].tagline == "A friendly greeter.")
        #expect(index.packages[0].sourceCrate == nil)
    }

    @Test("renders HTML containing every package's name and tagline")
    func renderIncludesAll() throws {
        let index = PackageIndex(packages: [
            .init(name: "swift-uuid", module: "UUID", tagline: "UUIDv4/6/7 + ULID.", repo: "https://x", version: "0.1.0", sourceCrate: "uuid", tier: "encoding"),
            .init(name: "swift-prometheus", module: "Prometheus", tagline: "swift-metrics → Prometheus.", repo: "https://x", version: "0.1.0", sourceCrate: "prometheus-client", tier: "observability"),
        ])
        let html = SiteGenerator.renderIndex(index)
        #expect(html.contains("swift-uuid"))
        #expect(html.contains("UUIDv4/6/7 → ULID.") || html.contains("UUIDv4/6/7 + ULID."))
        #expect(html.contains("swift-prometheus"))
        #expect(html.contains("swift-metrics") && html.contains("Prometheus"))
        #expect(html.hasPrefix("<!DOCTYPE html>"))
    }

    @Test("renders an empty index without crashing")
    func renderEmpty() {
        let html = SiteGenerator.renderIndex(PackageIndex(packages: []))
        #expect(html.contains("No packages"))
    }
}

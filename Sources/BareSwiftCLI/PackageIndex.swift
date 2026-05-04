// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Foundation

struct PackageIndex: Codable, Sendable {
    let packages: [Entry]

    struct Entry: Codable, Sendable {
        let name: String
        let module: String
        let tagline: String
        let repo: String
        let version: String
        let sourceCrate: String?
        let tier: String

        enum CodingKeys: String, CodingKey {
            case name, module, tagline, repo, version, tier
            case sourceCrate = "source_crate"
        }
    }

    static func decode(from data: Data) throws -> PackageIndex {
        let decoder = JSONDecoder()
        return try decoder.decode(PackageIndex.self, from: data)
    }

    static func load(from url: URL) throws -> PackageIndex {
        let data = try Data(contentsOf: url)
        return try decode(from: data)
    }
}

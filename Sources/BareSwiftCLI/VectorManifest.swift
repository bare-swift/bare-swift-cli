// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Foundation

enum VectorManifest {
    /// Parse a manifest into ordered entries. One path or glob per line; lines
    /// starting with `#` (after trimming) are comments; blank lines are skipped.
    static func parse(string: String) throws -> [String] {
        var entries: [String] = []
        for line in string.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.isEmpty || trimmed.hasPrefix("#") { continue }
            entries.append(trimmed)
        }
        return entries
    }

    static func parse(contentsOf url: URL) throws -> [String] {
        let raw = try String(contentsOf: url, encoding: .utf8)
        return try parse(string: raw)
    }
}

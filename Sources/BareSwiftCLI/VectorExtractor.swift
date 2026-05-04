// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Foundation

enum VectorExtractor {
    /// Copy each matched file from `crateRoot` into `outputDir`, preserving the
    /// relative path. Returns the number of files copied. Entries that match
    /// nothing are silently skipped (the manifest may legitimately reference
    /// optional fixtures).
    @discardableResult
    static func extract(
        entries: [String],
        from crateRoot: URL,
        to outputDir: URL
    ) throws -> Int {
        var total = 0
        for entry in entries {
            let matches = try resolveEntry(entry, in: crateRoot)
            for relativePath in matches {
                let src = crateRoot.appendingPathComponent(relativePath)
                let dst = outputDir.appendingPathComponent(relativePath)
                try FileManager.default.createDirectory(
                    at: dst.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                if FileManager.default.fileExists(atPath: dst.path) {
                    try FileManager.default.removeItem(at: dst)
                }
                try FileManager.default.copyItem(at: src, to: dst)
                total += 1
            }
        }
        return total
    }

    /// Resolve an entry (either a literal path or a `dir/*.ext` style glob)
    /// to a list of relative paths under `crateRoot`. Phase 0 supports only
    /// `dir/*.ext` (single trailing wildcard, single directory); literal paths
    /// pass through if they exist.
    private static func resolveEntry(_ entry: String, in crateRoot: URL) throws -> [String] {
        if !entry.contains("*") {
            let url = crateRoot.appendingPathComponent(entry)
            return FileManager.default.fileExists(atPath: url.path) ? [entry] : []
        }
        let components = entry.split(separator: "/", omittingEmptySubsequences: false).map(String.init)
        guard let last = components.last, components.count >= 1 else { return [] }
        let dir = components.dropLast().joined(separator: "/")
        let dirURL = crateRoot.appendingPathComponent(dir)
        guard FileManager.default.fileExists(atPath: dirURL.path) else { return [] }
        let names = try FileManager.default.contentsOfDirectory(atPath: dirURL.path)
        let regex = makeGlobRegex(last)
        let matches = names.filter { regex.firstMatch(in: $0, range: NSRange($0.startIndex..., in: $0)) != nil }
            .sorted()
        return matches.map { dir.isEmpty ? $0 : "\(dir)/\($0)" }
    }

    private static func makeGlobRegex(_ pattern: String) -> NSRegularExpression {
        var escaped = ""
        for ch in pattern {
            switch ch {
            case "*": escaped.append(".*")
            case ".", "+", "(", ")", "[", "]", "{", "}", "?", "|", "^", "$", "\\":
                escaped.append("\\")
                escaped.append(ch)
            default: escaped.append(ch)
            }
        }
        return try! NSRegularExpression(pattern: "^" + escaped + "$")
    }
}

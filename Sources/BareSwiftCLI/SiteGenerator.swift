// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

enum SiteGenerator {
    static func renderIndex(_ index: PackageIndex) -> String {
        let body: String
        if index.packages.isEmpty {
            body = "<p class=\"empty\">No packages yet.</p>"
        } else {
            let groups = Dictionary(grouping: index.packages, by: \.tier)
                .sorted(by: { $0.key < $1.key })
            body = groups.map { tier, entries in
                let items = entries.sorted(by: { $0.name < $1.name }).map(renderEntry).joined()
                return "<section><h2>\(escape(tier))</h2><ul class=\"pkgs\">\(items)</ul></section>"
            }.joined()
        }
        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="utf-8">
        <title>bare-swift</title>
        <style>
        body { font: 16px/1.5 -apple-system, BlinkMacSystemFont, sans-serif; max-width: 760px; margin: 2rem auto; padding: 0 1rem; color: #222; }
        h1 { margin-bottom: 0; }
        .tagline { color: #666; margin-top: .25rem; }
        h2 { border-bottom: 1px solid #eee; padding-bottom: .25rem; margin-top: 2rem; text-transform: capitalize; font-size: 1rem; color: #888; font-weight: 500; }
        ul.pkgs { list-style: none; padding: 0; }
        ul.pkgs li { padding: .5rem 0; border-bottom: 1px solid #f5f5f5; }
        ul.pkgs li a { font-weight: 600; text-decoration: none; }
        .desc { color: #555; }
        .empty { color: #888; font-style: italic; }
        .ver { color: #999; font-variant-numeric: tabular-nums; }
        </style>
        </head>
        <body>
        <h1>bare-swift</h1>
        <p class="tagline">Public Swift Package ecosystem complementing the Apple / swift-server stack.</p>
        \(body)
        <footer><p><a href="https://github.com/bare-swift/bare-swift">Source on GitHub</a></p></footer>
        </body>
        </html>
        """
    }

    private static func renderEntry(_ entry: PackageIndex.Entry) -> String {
        "<li><a href=\"\(escape(entry.repo))\">\(escape(entry.name))</a> <span class=\"ver\">v\(escape(entry.version))</span><br><span class=\"desc\">\(escape(entry.tagline))</span></li>"
    }

    private static func escape(_ s: String) -> String {
        s.replacingOccurrences(of: "&", with: "&amp;")
         .replacingOccurrences(of: "<", with: "&lt;")
         .replacingOccurrences(of: ">", with: "&gt;")
         .replacingOccurrences(of: "\"", with: "&quot;")
    }
}

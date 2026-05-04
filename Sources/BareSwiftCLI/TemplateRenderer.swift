// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

enum TemplateRenderer {
    /// Replaces every `{{KEY}}` occurrence in `template` with the corresponding
    /// value from `replacements`. Unknown placeholders are left intact.
    static func render(template: String, with replacements: [String: String]) -> String {
        var result = template
        for (key, value) in replacements {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }
}

// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import BareSwiftCLI

@Suite("TemplateRenderer")
struct TemplateRendererTests {
    @Test("substitutes single placeholder")
    func single() {
        let result = TemplateRenderer.render(
            template: "hello {{NAME}}",
            with: ["NAME": "world"]
        )
        #expect(result == "hello world")
    }

    @Test("substitutes multiple placeholders, including repeats")
    func multiple() {
        let result = TemplateRenderer.render(
            template: "{{A}} and {{B}} and {{A}}",
            with: ["A": "x", "B": "y"]
        )
        #expect(result == "x and y and x")
    }

    @Test("leaves unknown placeholders untouched")
    func unknown() {
        let result = TemplateRenderer.render(
            template: "{{KNOWN}} and {{UNKNOWN}}",
            with: ["KNOWN": "ok"]
        )
        #expect(result == "ok and {{UNKNOWN}}")
    }

    @Test("leaves text without placeholders untouched")
    func passthrough() {
        let result = TemplateRenderer.render(template: "hello", with: ["A": "x"])
        #expect(result == "hello")
    }
}

// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

import Testing
@testable import BareSwiftCLI

@Suite("NewCommand.deriveModuleName")
struct DeriveModuleNameTests {
    @Test("strips swift- prefix and PascalCases single-word names")
    func singleWord() {
        #expect(NewCommand.deriveModuleName(from: "swift-uuid") == "Uuid")
        #expect(NewCommand.deriveModuleName(from: "swift-hex") == "Hex")
    }

    @Test("PascalCases multi-word names")
    func multiWord() {
        #expect(NewCommand.deriveModuleName(from: "swift-json-pointer") == "JsonPointer")
        #expect(NewCommand.deriveModuleName(from: "swift-base64") == "Base64")
        #expect(NewCommand.deriveModuleName(from: "swift-x-y-z") == "XYZ")
    }

    @Test("handles names without swift- prefix")
    func noPrefix() {
        #expect(NewCommand.deriveModuleName(from: "uuid") == "Uuid")
        #expect(NewCommand.deriveModuleName(from: "json-pointer") == "JsonPointer")
    }
}

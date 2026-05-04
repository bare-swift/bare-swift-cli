// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
// Copyright (c) 2026 The bare-swift Project Authors.

import ArgumentParser

@main
struct BareSwift: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "bare-swift",
        abstract: "Tooling for the bare-swift package ecosystem.",
        version: "0.1.0",
        subcommands: [NewCommand.self, ExtractVectorsCommand.self, GenSiteCommand.self]
    )
}

# bare-swift-cli

Tooling for the bare-swift package ecosystem.

## Subcommands

- `bare-swift new <name>` — scaffold a new package using the bare-swift skeleton.
- `bare-swift extract-vectors --crate <path> --manifest <file>` — copy test vectors from a Rust crate into a package's `Tests/Vectors/`.
- `bare-swift gen-site` — regenerate the umbrella site `index.html` from `packages/index.json`.

## Install

```sh
git clone https://github.com/bare-swift/bare-swift-cli.git
cd bare-swift-cli
swift build -c release
cp .build/release/bare-swift /usr/local/bin/
```

## License

Apache 2.0 with LLVM exception. See [LICENSE](./LICENSE).

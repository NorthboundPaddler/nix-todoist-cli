# nix-todoist-cli

Nix flake for the official [Todoist CLI](https://github.com/Doist/todoist-cli).

## Usage

### Build

```bash
nix build
```

### Run

```bash
./result/bin/td --version
./result/bin/td today
```

### Install to your Nix profile

```bash
nix profile install .
td --version
```

## Update to a new version

When a new version of Todoist CLI is released:

```bash
# Set the new version - this will update versions.nix
./update.sh 1.75.0
```

If the build fails with hash mismatches, the error output will show the correct hashes. Update `versions.nix` manually:

```nix
{
  version = "1.75.0";
  srcHash = "sha256-<correct-src-hash>";
  npmHash = "sha256-<correct-npm-hash>";
}
```

Then run `nix build` again.

## File Structure

```
├── flake.nix      # Nix flake definition
├── versions.nix   # Version and hash definitions
├── update.sh      # Version update helper
└── flake.lock     # Nix lock file
```

## Requirements

- Nix 2.4+ with flakes enabled
- Linux x86_64

## Notes

- The `td` binary is a wrapper that invokes Node.js with the CLI entry point
- Platform support is Linux x86_64 only (native modules in `@napi-rs/keyring`)
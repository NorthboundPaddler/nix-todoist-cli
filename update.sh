#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_DIR="$SCRIPT_DIR"

if [ $# -ne 1 ]; then
  echo "Usage: $0 <version>"
  echo "Example: $0 1.75.0"
  exit 1
fi

NEW_VERSION="$1"

if [[ ! "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in semver format (e.g., 1.75.0)"
  exit 1
fi

echo "Updating todoist-cli to version $NEW_VERSION..."

cat > "$FLAKE_DIR/versions.nix" << EOF
{
  version = "$NEW_VERSION";
  srcHash = "";
  npmHash = "";
}
EOF

echo ""
echo "versions.nix updated. Running nix build to calculate hashes..."
echo ""

cd "$FLAKE_DIR"

if nix build 2>&1 | tee /tmp/nix-update-build.txt; then
  echo ""
  echo "Build succeeded! The package is ready."
  echo ""
  echo "To use the new version, run:"
  echo "  nix build"
  echo "  ./result/bin/td --version"
else
  echo ""
  echo "Build failed - this is expected if hashes need updating."
  echo ""
  grep -A1 "got:" /tmp/nix-update-build.txt | head -10
  echo ""
  echo "If you see hash mismatches above, update versions.nix with the correct hashes."
  echo "The format should be:"
  echo '  srcHash = "sha256-<hash>";'
  echo '  npmHash = "sha256-<hash>";'
fi
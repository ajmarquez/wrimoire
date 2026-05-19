#!/bin/zsh

set -euo pipefail

if [[ "${CI_XCODE_CLOUD:-}" != "TRUE" ]]; then
  echo "ci_post_clone.sh is intended for Xcode Cloud only."
  exit 0
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "error: Homebrew is unavailable in this Xcode Cloud environment."
  exit 1
fi

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "Installing SwiftLint for Xcode Cloud..."
  brew install swiftlint
else
  echo "SwiftLint already installed."
fi

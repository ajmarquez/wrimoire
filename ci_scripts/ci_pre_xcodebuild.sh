#!/bin/zsh

set -euo pipefail

if [[ "${CI_XCODE_CLOUD:-}" != "TRUE" ]]; then
  echo "ci_pre_xcodebuild.sh is intended for Xcode Cloud only."
  exit 0
fi

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "error: SwiftLint is not installed. ci_post_clone.sh should install it first."
  exit 1
fi

if [[ -z "${CI_WORKSPACE_PATH:-}" ]]; then
  echo "error: CI_WORKSPACE_PATH is unavailable."
  exit 1
fi

cd "${CI_WORKSPACE_PATH}"

echo "Running SwiftLint before xcodebuild..."
swiftlint --strict --no-cache

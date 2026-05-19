# Xcode Cloud Setup

Wrimoire can use Xcode Cloud for CI/CD.

## What Is Ready In The Repo

- Shared schemes exist:
  - `Wrimoire`
  - `Wrimoire-UITests`
- Local validation already maps well to Xcode Cloud:
  - macOS build and unit tests through `Wrimoire`
  - iOS simulator UI tests through `Wrimoire-UITests`
- Custom Xcode Cloud scripts exist in `ci_scripts/`:
  - `ci_post_clone.sh`
  - `ci_pre_xcodebuild.sh`

## What Still Must Be Done In Apple Tools

Apple requires the first Xcode Cloud workflow to be configured from Xcode while signed in with an Apple Developer/App Store Connect account that has the right permissions.

After the first build exists, workflows can be edited or created in either Xcode or App Store Connect.

## Recommended First Workflow For Wrimoire

Create a validation workflow first:

- Start condition:
  - branch changes on `main`
  - pull request changes, if available for the connected Git provider
- Actions:
  - build
  - test
- Scheme:
  - `Wrimoire`
- Destination:
  - latest macOS available in Xcode Cloud

This gives Wrimoire a stable CI baseline without blocking on distribution/signing details.

## Recommended Second Workflow

Add a UI validation workflow next:

- Start condition:
  - branch changes on `main`
  - or pull request changes
- Actions:
  - test
- Scheme:
  - `Wrimoire-UITests`
- Destination:
  - latest iPhone simulator available in Xcode Cloud

## Suggested Release Workflow Later

Once app records, signing, and TestFlight plans are ready:

- Start condition:
  - manual
  - or tag changes
- Actions:
  - archive
- Post-action:
  - distribute to TestFlight

## Notes

- `ci_post_clone.sh` installs `swiftlint` with Homebrew because Xcode Cloud images do not include third-party tools by default.
- `ci_pre_xcodebuild.sh` runs `swiftlint --strict --no-cache` before Xcode Cloud starts `xcodebuild`.
- If future workflows need secrets, add them as Xcode Cloud environment variables instead of hardcoding values in scripts.

# AGENTS.md

Guidance for coding agents working in `/Users/ajmarquez/Development/wrimoire`.

## Project Overview

- `Wrimoire` is the implementation repo.
- `/Users/ajmarquez/Development/Nothulhu` is a reference repo only. Do not implement product work there unless the user explicitly asks.
- Wrimoire is a SwiftUI app targeting Apple platforms with a macOS-first product and architecture posture.
- Current product direction:
  - writing app for drafts and folios
  - `Project` as the umbrella container for folios
  - project sidebar + folio workspace
  - SwiftData persistence and iCloud/CloudKit sync planned

## Repository Layout

- `Wrimoire/`
  - app source tree
  - `App/` holds app shell and feature areas
  - nearby test folders use the `_Tests` suffix under their related domain or feature area
- `WrimoireUITests`
  - Xcode UI test target and scheme name
- `Config/`
  - platform-specific configuration such as iOS plist data
- `Wrimoire.xcodeproj/`
  - Xcode project configuration and shared schemes
- `Makefile`
  - primary developer and agent command entrypoint

## Current State

- The repo currently contains a macOS-first themed shell scaffold.
- The app builds locally on the current installed toolchain when Xcode is healthy.
- SwiftData-backed `Project` and `Folio` models are implemented.
- The project sidebar, folio list, and folio editor now run against real persistence instead of placeholder data.
- The app container bootstrap supports local persistence first with a CloudKit-aware fallback path.

## Architecture Expectations

- Prefer modularization and readable code architecture.
- Avoid monolith files that mix screen layout, state, helpers, and supporting components in one place.
- Prefer folder-based composition where components and subcomponents live in focused files.
- Split code by responsibility instead of appending all behavior into one major screen file.
- When a file starts accumulating unrelated concerns, break it up before continuing.
- Prefer feature-first organization with nearby `_Tests` folders for UI and unit tests close to the production code they validate.

## Xcode / Environment

- Use `Wrimoire.xcodeproj`.
- Assume macOS with Xcode and command-line developer tools installed.
- Prefer repo-local derived data during command-line runs; the Makefile already does this.
- After system or Xcode upgrades, re-verify build and test commands before relying on old assumptions.

## Build / Validation Commands

Use these from the repo root:

- `make help`
- `make doctor`
- `make list-schemes`
- `make build-macos`
- `make build-ios-sim`
- `make lint`
- `make test`
- `make test-ui`
- `make pre-push`

Raw fallback examples:

- `xcodebuild -list -project Wrimoire.xcodeproj`
- `xcodebuild -project Wrimoire.xcodeproj -scheme Wrimoire -destination 'platform=macOS,arch=arm64' -derivedDataPath ./DerivedData CODE_SIGNING_ALLOWED=NO build`

## Required Workflow

- Check for uncommitted changes first and do not overwrite user edits.
- Read the relevant files before changing behavior.
- Avoid unnecessary edits to `Wrimoire.xcodeproj/project.pbxproj`.
- Keep cross-platform compatibility intact unless the task explicitly narrows platform scope.
- Run `swiftlint` before commit.
- Run `make pre-push` before push.
- If validation is blocked by current Xcode or toolchain health, state that explicitly in the final summary instead of implying checks passed.
- Summarize what changed and which validation commands were run.

## Testing Convention

- Tests should live close to the production code they validate using nearby `_Tests` folders.
- Target membership decides whether a test file is UI-test or unit-test code.
- The current default automated test command is `make test`, which runs the macOS unit test suite.
- Run `make test-ui` when UI coverage is needed or when preparing to push.
- As new domains are added, place their tests in sibling `_Tests` folders rather than a single growing top-level test dump.

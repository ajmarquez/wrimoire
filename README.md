# Wrimoire

A writing app for drafts and folios.

## Foundation

- Implementation repo: `/Users/ajmarquez/Development/wrimoire`
- Reference repo: `/Users/ajmarquez/Development/Nothulhu`
- Platform posture: universal Apple app target for macOS, iPadOS, and iOS
- Current development focus: macOS-first UX and architecture

## App Direction

Wrimoire is being shaped as a focused writing app, taking structural inspiration from tools like Ulysses:

- projects in the sidebar
- folios scoped to a selected project
- SwiftData persistence
- iCloud sync through CloudKit

The first scaffold uses a macOS-oriented `NavigationSplitView` so the information architecture starts from the desktop experience, while keeping the target layout compatible with iPad and iPhone later.

## Xcode Cloud

Wrimoire is partially prepared for Xcode Cloud with shared schemes and repo-level `ci_scripts/`.

See [XcodeCloud.md](/Users/ajmarquez/Development/wrimoire/XcodeCloud.md:1) for the remaining Apple-side setup steps and the recommended first workflows.

# Wrimoire Plan

This document is a handoff guide for future work in Wrimoire.

## Current State

- Wrimoire is a macOS-first SwiftUI writing app scaffold with universal Apple platform targets.
- `Project` and `Folio` SwiftData models are implemented.
- The app shell is a three-column `NavigationSplitView`:
  - `Projects`
  - `Folios`
  - `Editor`
- The folio editor is body-first:
  - no title field in the editor
  - larger serif text
  - cream paper background
  - accent-colored caret
- Project creation now prompts for a name before insertion.
- The sidebar and folio list have been visually simplified to remove unnecessary icons.
- Repo tooling is in place:
  - `Makefile`
  - `swiftlint`
  - nearby `_Tests` folders
  - macOS unit tests and iOS UI launch test

## What Comes Next

### Product / UX

- Add explicit rename flows for `Project` and `Folio`.
- Decide the long-term title strategy for folios:
  - derived first line only
  - explicit title stored separately
  - rename from list / inspector / command
- Add delete/archive flows for projects and folios.
- Improve the writing workflow around selection and creation:
  - create folio and focus editor immediately
  - better empty states
  - better keyboard-driven creation/navigation
- Add writing preferences:
  - font choice
  - text size
  - line spacing
  - editor width

### Persistence / Sync

- Finish the real iCloud / CloudKit setup path beyond the current CloudKit-aware bootstrap.
- Verify schema materialization and migration expectations once CloudKit is enabled for real accounts.
- Add more coverage around project/folio mutations once delete/rename flows land.

### Mac-Specific Refinement

- Tighten the `View` menu layout controls and verify them in live macOS use.
- Revisit whether the macOS shell should remain SwiftUI-owned or move to an AppKit-owned split-view shell.
- If macOS interaction polish becomes a top priority, evaluate:
  - `NSSplitViewController` shell
  - `NSHostingController` for each pane
  - SwiftUI content views reused inside AppKit containers

## Known Issue: Editor-Only / Fullscreen Layout

### Goal

Wrimoire should be able to hide the two leading columns and show only the editor from the macOS `View` menu.

### What Was Implemented

- `WritingLayoutController` owns layout state for:
  - all columns
  - folios + editor
  - editor only
- macOS `View` menu commands were added in `WrimoireApp.swift`.
- A macOS AppKit bridge registers the underlying split view and attempts to collapse the leading columns explicitly.

### Findings So Far

- `NavigationSplitViewVisibility.detailOnly` is the correct SwiftUI concept for editor-only mode.
- In practice, Wrimoire has not yet been verified to reliably collapse to editor-only in live macOS runtime.
- `Command-.` was a bad shortcut choice because it conflicts with the standard macOS Cancel shortcut.
- The safer temporary layout shortcuts are:
  - `Option-Command-1` show all columns
  - `Option-Command-2` show folios and editor
  - `Option-Command-3` show editor only
- The console noise seen during testing included:
  - `ViewBridge to RemoteViewService Terminated ... NSViewBridgeErrorCanceled`
  - this did not by itself prove the layout command path was correct or incorrect

### Likely Next Debug Steps

- Verify whether the `View -> Show Editor Only` menu item fires and whether the split-view controller receives the collapse request.
- Add temporary logging around:
  - menu command execution
  - `WritingLayoutController.showEditorOnly()`
  - split-view item collapse state before and after command execution
- If SwiftUI continues to resist reliable editor-only behavior on macOS, consider a macOS-only AppKit shell with:
  - `NSSplitViewController`
  - `NSSplitViewItem`
  - `NSHostingController` wrapping the existing SwiftUI panes

## Recommended Next Task

If continuing product work first:
- implement project and folio rename/delete flows

If continuing platform polish first:
- debug and finish the editor-only macOS layout command path before revisiting gestures

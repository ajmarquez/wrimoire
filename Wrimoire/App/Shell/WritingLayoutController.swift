import Combine
import SwiftUI
#if os(macOS)
import AppKit
#endif

@MainActor
final class WritingLayoutController: ObservableObject {
    @Published var columnVisibility: NavigationSplitViewVisibility = .all
    @Published var preferredCompactColumn: NavigationSplitViewColumn = .detail

#if os(macOS)
    private weak var splitViewController: NSSplitViewController?
#endif

    func showAllColumns() {
        columnVisibility = .all
        preferredCompactColumn = .detail
#if os(macOS)
        applyMacColumnLayout()
#endif
    }

    func showFolioListAndEditor() {
        columnVisibility = .doubleColumn
        preferredCompactColumn = .content
#if os(macOS)
        applyMacColumnLayout()
#endif
    }

    func showEditorOnly() {
        columnVisibility = .detailOnly
        preferredCompactColumn = .detail
#if os(macOS)
        applyMacColumnLayout()
#endif
    }

#if os(macOS)
    func registerMacSplitViewController(_ splitViewController: NSSplitViewController) {
        self.splitViewController = splitViewController
        applyMacColumnLayout()
    }

    private func applyMacColumnLayout() {
        guard let splitViewController else {
            return
        }

        let splitViewItems = splitViewController.splitViewItems

        switch columnVisibility {
        case .all:
            setCollapsed(false, at: 0, in: splitViewItems)
            setCollapsed(false, at: 1, in: splitViewItems)
        case .doubleColumn:
            setCollapsed(true, at: 0, in: splitViewItems)
            setCollapsed(false, at: 1, in: splitViewItems)
        case .detailOnly:
            setCollapsed(true, at: 0, in: splitViewItems)
            setCollapsed(true, at: 1, in: splitViewItems)
        default:
            break
        }
    }

    private func setCollapsed(
        _ collapsed: Bool,
        at index: Int,
        in splitViewItems: [NSSplitViewItem]
    ) {
        guard splitViewItems.indices.contains(index) else {
            return
        }

        let item = splitViewItems[index]
        guard item.isCollapsed != collapsed else {
            return
        }

        item.animator().isCollapsed = collapsed
    }
#endif
}

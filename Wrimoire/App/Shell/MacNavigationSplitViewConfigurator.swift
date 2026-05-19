#if os(macOS)
import AppKit
import SwiftUI

struct MacNavigationSplitViewConfigurator: NSViewRepresentable {
    let writingLayoutController: WritingLayoutController

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        view.postsFrameChangedNotifications = true

        DispatchQueue.main.async {
            configure(using: view, coordinator: context.coordinator)
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(using: nsView, coordinator: context.coordinator)
        }
    }

    private func configure(using view: NSView, coordinator: Coordinator) {
        guard let splitViewController = locateSplitViewController(from: view) else {
            return
        }

        coordinator.splitViewController = splitViewController
        writingLayoutController.registerMacSplitViewController(splitViewController)
        splitViewController.minimumThicknessForInlineSidebars = 200
        splitViewController.splitView.autosaveName = "WrimoireNavigationSplitView"

        let itemCount = splitViewController.splitViewItems.count

        for (index, item) in splitViewController.splitViewItems.enumerated() {
            let isLeadingColumn = index < itemCount - 1

            item.canCollapse = isLeadingColumn
            item.canCollapseFromWindowResize = isLeadingColumn
            item.isSpringLoaded = isLeadingColumn
        }
    }

    private func locateSplitViewController(from view: NSView) -> NSSplitViewController? {
        var responder: NSResponder? = view

        while let currentResponder = responder {
            if let splitViewController = currentResponder as? NSSplitViewController {
                return splitViewController
            }

            responder = currentResponder.nextResponder
        }

        guard let rootViewController = view.window?.contentViewController else {
            return nil
        }

        return findSplitViewController(in: rootViewController)
    }

    private func findSplitViewController(in viewController: NSViewController) -> NSSplitViewController? {
        if let splitViewController = viewController as? NSSplitViewController {
            return splitViewController
        }

        for childViewController in viewController.children {
            if let splitViewController = findSplitViewController(in: childViewController) {
                return splitViewController
            }
        }

        return nil
    }
}

extension MacNavigationSplitViewConfigurator {
    final class Coordinator {
        weak var splitViewController: NSSplitViewController?
    }
}
#endif

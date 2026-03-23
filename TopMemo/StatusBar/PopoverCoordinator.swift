import AppKit
import SwiftUI

@MainActor
final class PopoverCoordinator: NSObject, NSPopoverDelegate {
    private let statusBarController: StatusBarController
    private let viewModel: NotesViewModel
    private let popover = NSPopover()
    private var eventMonitor: Any?
    private lazy var hostingController = NSHostingController(
        rootView: NotesRootView(
            viewModel: viewModel,
            closePopover: { [weak self] in
                self?.closePopover()
            }
        )
    )

    init(statusBarController: StatusBarController, viewModel: NotesViewModel) {
        self.statusBarController = statusBarController
        self.viewModel = viewModel
        super.init()
        configurePopover()
        configureStatusButton()
    }

    @objc
    func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }

    func showNewMemoOnLaunch() {
        guard !popover.isShown, let button = statusBarController.button else {
            return
        }

        viewModel.startNewMemo()
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        startEventMonitor()
    }

    func popoverDidClose(_ notification: Notification) {
        stopEventMonitor()
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = AppTheme.popoverSize
        popover.delegate = self
        popover.contentViewController = hostingController
    }

    private func configureStatusButton() {
        guard let button = statusBarController.button else {
            return
        }

        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp])
    }

    private func showPopover() {
        guard let button = statusBarController.button else {
            return
        }

        viewModel.handlePopoverOpened()
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        startEventMonitor()
    }

    private func closePopover() {
        popover.performClose(nil)
        stopEventMonitor()
    }

    private func startEventMonitor() {
        stopEventMonitor()

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self, self.popover.isShown else {
                return event
            }

            if event.keyCode == 53 {
                self.closePopover()
                return nil
            }

            return event
        }
    }

    private func stopEventMonitor() {
        guard let eventMonitor else {
            return
        }

        NSEvent.removeMonitor(eventMonitor)
        self.eventMonitor = nil
    }
}

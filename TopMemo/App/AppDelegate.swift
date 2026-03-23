import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var popoverCoordinator: PopoverCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let notesViewModel = NotesViewModel(store: NotesStore())
        let statusBarController = StatusBarController()
        popoverCoordinator = PopoverCoordinator(
            statusBarController: statusBarController,
            viewModel: notesViewModel
        )

        DispatchQueue.main.async { [weak self] in
            self?.popoverCoordinator?.showNewMemoOnLaunch()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }
}

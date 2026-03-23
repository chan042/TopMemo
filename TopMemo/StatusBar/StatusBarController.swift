import AppKit

final class StatusBarController {
    let statusItem: NSStatusItem
    private let statusBarIconName = "TopMemoic"

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureButton()
    }

    var button: NSStatusBarButton? {
        statusItem.button
    }

    private func configureButton() {
        guard let button = statusItem.button else {
            return
        }

        button.image = makeStatusBarImage()
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
        button.toolTip = "TopMemo"
    }

    private func makeStatusBarImage() -> NSImage {
        if let resourceURL = Bundle.main.url(forResource: statusBarIconName, withExtension: "png"),
           let image = NSImage(contentsOf: resourceURL) {
            return makeSquareStatusBarImage(from: image)
        }

        let image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "TopMemo") ?? NSImage()
        image.isTemplate = false
        return image
    }

    private func makeSquareStatusBarImage(from sourceImage: NSImage) -> NSImage {
        let targetSize = NSSize(width: 18, height: 18)
        let canvas = NSImage(size: targetSize)
        canvas.lockFocus()

        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: targetSize)).fill()

        let sourceSize = sourceImage.size
        let scale = min(targetSize.width / sourceSize.width, targetSize.height / sourceSize.height)
        let drawSize = NSSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
        let drawOrigin = NSPoint(
            x: (targetSize.width - drawSize.width) / 2,
            y: (targetSize.height - drawSize.height) / 2
        )

        sourceImage.draw(
            in: NSRect(origin: drawOrigin, size: drawSize),
            from: NSRect(origin: .zero, size: sourceSize),
            operation: .sourceOver,
            fraction: 1.0
        )

        canvas.unlockFocus()
        canvas.isTemplate = false
        return canvas
    }
}

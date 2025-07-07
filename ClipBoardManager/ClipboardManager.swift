

import Foundation
import AppKit

class ClipboardManager: ObservableObject {
    @Published var items: [ClipboardItem] = []
    private var lastChangeCount = NSPasteboard.general.changeCount

    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        guard pasteboard.changeCount != lastChangeCount else { return }
        lastChangeCount = pasteboard.changeCount

        if let copiedText = pasteboard.string(forType: .string) {
            let item = ClipboardItem(content: copiedText,
                                     timestamp: Date(),
                                     device: Host.current().localizedName ?? "Unknown")
            items.insert(item, at: 0)
        }
    }

    func paste(text: String) {
        let script = """
        tell application "System Events"
            keystroke "\(text)"
        end tell
        """
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            scriptObject.executeAndReturnError(&error)
        }
    }
}

import Cocoa
import SwiftUI
import Carbon.HIToolbox

class AppDelegate: NSObject, NSApplicationDelegate {
    var clipboardMonitor: ClipboardMonitor?
    var popupWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        clipboardMonitor = ClipboardMonitor()
        clipboardMonitor?.startMonitoring()

        HotkeyManager.shared.registerHotkey(modifiers: [.control], key: kVK_ANSI_V) {
            self.showPopup()
        }
    }

    func showPopup() {
        if popupWindow != nil {
            popupWindow?.close()
        }

        guard let monitor = clipboardMonitor else { return }

        print("🪟 Showing clipboard popup")

        let popup = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 320, height: 450),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        popup.isReleasedWhenClosed = false
        popup.level = .floating
        popup.hasShadow = true
        popup.center()

        popup.contentView = NSHostingView(rootView: ContentView(monitor: monitor))
        popup.makeKeyAndOrderFront(nil)
        self.popupWindow = popup
    }
}

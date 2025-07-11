import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popupWindow: NSWindow!
    var monitor = ClipboardMonitor()
    
    var peerDiscovery = PeerDiscoveryService()
        var peerAdvertiser: PeerAdvertiserService?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up ⌃ + V global shortcut
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.modifierFlags.contains(.control) && event.keyCode == 9 {
                self.togglePopup()
            }
        }
        peerAdvertiser = PeerAdvertiserService(port: 8888)
                peerAdvertiser?.start()

        
        

        
        // Setup system tray icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
            button.action = #selector(togglePopup)
        }

        createPopup()
    }
    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func createPopup() {
        let contentView = ContentView(monitor: monitor)
        popupWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        popupWindow.center()
        popupWindow.isReleasedWhenClosed = false
        popupWindow.level = .floating
        popupWindow.isOpaque = false
        popupWindow.backgroundColor = .clear
        popupWindow.contentView = NSHostingView(rootView: contentView)
    }

    @objc func togglePopup() {
        if popupWindow.isVisible {
            popupWindow.orderOut(nil)
        } else {
            popupWindow.makeKeyAndOrderFront(nil)
            popupWindow.center()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

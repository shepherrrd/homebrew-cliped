import Cocoa

func simulatePaste() {
    let src = CGEventSource(stateID: .combinedSessionState)
    let cmdDown = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: true)
    let vDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true)
    let vUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
    let cmdUp = CGEvent(keyboardEventSource: src, virtualKey: 0x38, keyDown: false)

    cmdDown?.flags = .maskCommand
    vDown?.flags = .maskCommand
    vUp?.flags = .maskCommand

    let loc = CGEventTapLocation.cghidEventTap

    cmdDown?.post(tap: loc)
    vDown?.post(tap: loc)
    vUp?.post(tap: loc)
    cmdUp?.post(tap: loc)
}

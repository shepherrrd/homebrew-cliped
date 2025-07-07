import Carbon.HIToolbox
import Cocoa

var hotkeyCallback: (() -> Void)? = nil

func hotkeyCallbackBridge(
    nextHandler: EventHandlerCallRef?,
    theEvent: EventRef?,
    userData: UnsafeMutableRawPointer?
) -> OSStatus {
    hotkeyCallback?()
    return noErr
}

class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotkeyRef: EventHotKeyRef?

    func registerHotkey(modifiers: NSEvent.ModifierFlags, key: Int, handler: @escaping () -> Void) {
        hotkeyCallback = handler

        var eventHandler: EventHandlerRef?
        let spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(GetApplicationEventTarget(),
                            hotkeyCallbackBridge,
                            1, [spec], nil, &eventHandler)

        let modFlags =
            (modifiers.contains(.command) ? UInt32(cmdKey) : 0) |
            (modifiers.contains(.option) ? UInt32(optionKey) : 0) |
            (modifiers.contains(.control) ? UInt32(controlKey) : 0)

        RegisterEventHotKey(UInt32(key), modFlags,
                            EventHotKeyID(signature: OSType(1234), id: UInt32(key)),
                            GetApplicationEventTarget(), 0, &hotkeyRef)
    }
}

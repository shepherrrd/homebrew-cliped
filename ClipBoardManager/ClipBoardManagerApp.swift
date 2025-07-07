import SwiftUI

@main
struct ClipBoardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // No Settings UI
        }
    }
}

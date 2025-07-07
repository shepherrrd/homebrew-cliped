import Foundation
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var history: [String] = []

    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount
    private let historyKey = "ClipboardHistory"

    func startMonitoring() {
        print("✅ Clipboard monitoring started.")

        loadHistory()

        

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let pb = NSPasteboard.general

            if pb.changeCount != self.lastChangeCount {
                self.lastChangeCount = pb.changeCount

                let copiedString = pb.string(forType: .string)

                if let string = copiedString, !string.isEmpty {
                    print("📋 Clipboard changed: '\(string)'")

                    DispatchQueue.main.async {
                        if self.history.first != string && !self.history.contains(string) {
                            self.history.insert(string, at: 0)
                            if self.history.count > 20 {
                                self.history.removeLast()
                            }
                            self.saveHistory()
                        }
                    }
                } else {
                    print("⚠️ Clipboard changed, but content is empty or not a string.")
                }
            }
        }
    }

    func saveHistory() {
        UserDefaults.standard.set(history, forKey: historyKey)
        print("💾 History saved with \(history.count) items.")
    }

    func loadHistory() {
        if let saved = UserDefaults.standard.stringArray(forKey: historyKey) {
            history = saved
            print("📂 History loaded with \(history.count) items.")
        } else {
            print("📂 No previous history found.")
        }
    }
}

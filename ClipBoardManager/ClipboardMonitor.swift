import Foundation
import AppKit



class ClipboardMonitor: ObservableObject {
    @Published var history: [ClipboardItem] = []
    private let historyKey = "clipboardHistory"
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var undoStack: [[ClipboardItem]] = []

    init() {
        loadHistory()
        startMonitoring()
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != lastChangeCount,
           let newString = pasteboard.string(forType: .string) {
            
            let newItem = ClipboardItem(
                content: newString,
                timestamp: Date(),
                device: Host.current().localizedName ?? "Unknown"
            )

            DispatchQueue.main.async {
                if !self.history.contains(where: { $0.content == newItem.content }) {
                    self.history.insert(newItem, at: 0)
                    self.saveHistory()
                }
            }

            lastChangeCount = pasteboard.changeCount
        }
    }

    // MARK: - History Persistence

    func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
            print("💾 History saved with \(history.count) items.")
        } catch {
            print("❌ Failed to save clipboard history: \(error)")
        }
    }

    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            print("📂 No previous history found.")
            return
        }
        do {
            history = try JSONDecoder().decode([ClipboardItem].self, from: data)
            print("📂 History loaded with \(history.count) items.")
        } catch {
            print("❌ Failed to load history: \(error)")
        }
    }

    // MARK: - Clear & Undo

    func clearHistory() {
        undoStack.append(history)
        history.removeAll()
        saveHistory()
        print("🧹 History cleared.")
    }

    func undoClear() {
        guard let last = undoStack.popLast() else { return }
        history = last
        saveHistory()
        print("↩️ Undo clear.")
    }

    func deleteItem(id: UUID) {
        undoStack.append(history)
        history.removeAll { $0.id == id }
        saveHistory()
        print("🗑️ Deleted item.")
    }

    func undoDelete() {
        undoClear() // Since we're saving full history snapshots
    }
}

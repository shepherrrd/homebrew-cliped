import SwiftUI
import AppKit

struct ContentView: View {
    @ObservedObject var monitor: ClipboardMonitor
    @State private var searchText: String = ""
    @State private var showClearAlert: Bool = false
    @State private var expandedItems: Set<UUID> = []
    @State private var lastClearedHistory: [ClipboardItem] = []
    @State private var lastDeletedItem: ClipboardItem?
    @State private var showUndoToast = false
    @State private var toastMessage = ""

    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return monitor.history
        } else {
            return monitor.history.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("📋 Clipboard History")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showClearAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .help("Clear clipboard history")
                .alert(isPresented: $showClearAlert) {
                    Alert(
                        title: Text("Clear History?"),
                        message: Text("Are you sure you want to delete all clipboard entries?"),
                        primaryButton: .destructive(Text("Clear")) {
                            lastClearedHistory = monitor.history
                            monitor.clearHistory()
                            toastWithUndo("Cleared all clipboard items") {
                                monitor.history = lastClearedHistory
                                monitor.saveHistory()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            .padding()

            TextField("Search clipboard...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Divider()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(filteredHistory) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.content, forType: .string)
                                    monitor.saveHistory()
                                    NSApp.keyWindow?.close()
                                }) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            Text(truncatedText(for: item))
                                                .font(.body)
                                                .lineLimit(1)
                                            Spacer()
                                            Button(action: {
                                                toggleExpand(item)
                                            }) {
                                                Text(expandedItems.contains(item.id) ? "Less" : "More")
                                                    .font(.caption)
                                                    .foregroundColor(.blue)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }

                                        if expandedItems.contains(item.id) {
                                            Text(item.content)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .padding(.top, 2)
                                        }

                                        Text("📅 \(formattedDate(item.timestamp)) • 🖥 \(item.device)")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())

                                Button(action: {
                                    lastDeletedItem = item
                                    monitor.history.removeAll { $0.id == item.id }
                                    monitor.saveHistory()
                                    toastWithUndo("Deleted item") {
                                        if let deleted = lastDeletedItem {
                                            monitor.history.append(deleted)
                                            monitor.saveHistory()
                                        }
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .help("Delete item")
                                .buttonStyle(BorderlessButtonStyle())
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
            }

            if showUndoToast {
                HStack {
                    Text(toastMessage)
                    Spacer()
                    Button("Undo") {
                        showUndoToast = false
                        undoAction?()
                    }
                    .buttonStyle(LinkButtonStyle())
                }
                .padding()
                .background(.ultraThinMaterial)
                .transition(.move(edge: .bottom))
            }
        }
        .frame(width: 500, height: 500)
        .background(.ultraThinMaterial)
    }

    // MARK: - Helper Methods

    private func toggleExpand(_ item: ClipboardItem) {
        if expandedItems.contains(item.id) {
            expandedItems.remove(item.id)
        } else {
            expandedItems.insert(item.id)
        }
    }

    private func truncatedText(for item: ClipboardItem) -> String {
        item.content.count > 60
            ? String(item.content.prefix(60)) + "..."
            : item.content
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    @State private var undoAction: (() -> Void)? = nil

    private func toastWithUndo(_ message: String, undo: @escaping () -> Void) {
        toastMessage = message
        undoAction = undo
        withAnimation {
            showUndoToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            withAnimation {
                showUndoToast = false
            }
        }
    }
}

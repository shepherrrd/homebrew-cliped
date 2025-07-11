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
    @State private var undoAction: (() -> Void)? = nil

    var filteredHistory: [ClipboardItem] {
        if searchText.isEmpty {
            return monitor.history
        } else {
            return monitor.history.filter {
                switch $0.content {
                case .text(let value):
                    return value.localizedCaseInsensitiveContains(searchText)
                case .image:
                    return false
                }
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
                    let window = NSWindow(
                        contentRect: NSRect(x: 0, y: 0, width: 500, height: 600),
                        styleMask: [.titled, .closable],
                        backing: .buffered, defer: false)
                    window.center()
                    window.title = "Settings"

                    let discovery = PeerDiscoveryService()
                    discovery.startBrowsing()

                    window.contentView = NSHostingView(
                        rootView: SyncSettingsView(
                            discoveryService: discovery,
                            onPeerAdd: { hostname in
                                monitor.addPeer(host: hostname) 
                            }
                        )
                    )

                    window.makeKeyAndOrderFront(nil)
                }) {
                    Image(systemName: "gearshape")
                }
                .help("Settings")


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
                                    switch item.content {
                                    case .text(let value):
                                        NSPasteboard.general.setString(value, forType: .string)
                                    case .image(let data):
                                        if let image = NSImage(data: data) {
                                            NSPasteboard.general.writeObjects([image])
                                        }
                                    }
                                    monitor.saveHistory()
                                    NSApp.keyWindow?.close()
                                }) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack {
                                            displayContent(for: item)
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
                                            if case let .text(fullText) = item.content {
                                                Text(fullText)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .padding(.top, 2)
                                            }
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
                                            monitor.history.insert(deleted, at: 0)
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

    // MARK: - Helpers

    private func toggleExpand(_ item: ClipboardItem) {
        if expandedItems.contains(item.id) {
            expandedItems.remove(item.id)
        } else {
            expandedItems.insert(item.id)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

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

    @ViewBuilder
    private func displayContent(for item: ClipboardItem) -> some View {
        switch item.content {
        case .text(let text):
            Text(text.count > 60 ? String(text.prefix(60)) + "..." : text)
                .font(.body)
                .lineLimit(1)

        case .image(let data):
            if let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                Text("⚠️ Invalid image")
                    .foregroundColor(.red)
            }
        }
    }



}

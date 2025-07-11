
import Foundation
import AppKit
import Network
import Compression

class ClipboardMonitor: ObservableObject {
    @Published var history: [ClipboardItem] = []
    
    @Published var peers: [String] = []
    private let historyKey = "clipboardHistory"
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var undoStack: [[ClipboardItem]] = []

    private var listener: NWListener?
    private var connections: [NWConnection] = []
    private let sharedToken = "zzub-shared-key"
    var syncEnabled = true

    init() {
        loadHistory()
        startMonitoring()
        startSyncServer()
    }

    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        if pasteboard.changeCount != lastChangeCount {
            defer { lastChangeCount = pasteboard.changeCount }

            if let image = NSImage(pasteboard: pasteboard),
               let tiff = image.tiffRepresentation {
                let item = ClipboardItem(content: .image(tiff),
                                         timestamp: Date(),
                                         device: Host.current().localizedName ?? "Unknown")
                insertIfNew(item: item, broadcast: true)
                return
            }

            if let copiedText = pasteboard.string(forType: .string), !copiedText.isEmpty {
                let item = ClipboardItem(content: .text(copiedText),
                                         timestamp: Date(),
                                         device: Host.current().localizedName ?? "Unknown")
                insertIfNew(item: item, broadcast: true)
            }
        }
    }

    func insertIfNew(item: ClipboardItem, broadcast: Bool = false) {
        DispatchQueue.main.async {
            if !self.history.contains(where: { $0.content == item.content }) {
                self.history.insert(item, at: 0)
                self.saveHistory()
                if broadcast && self.syncEnabled {
                    self.broadcastClipboard(item)
                }
            }
        }
    }

    private func broadcastClipboard(_ item: ClipboardItem) {
        do {
            let rawData = try JSONEncoder().encode(item)
            let compressed = compress(rawData)
            let packet = ClipboardTransferPacket(token: sharedToken, rawData: compressed)
            let encodedPacket = try JSONEncoder().encode(packet)

            for conn in connections {
                conn.send(content: encodedPacket, completion: .contentProcessed { _ in })
            }
        } catch {
            print("❌ Broadcast error: \(error)")
        }
    }

    private func compress(_ data: Data) -> Data {
        let bufferSize = 4096
        let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { dstBuffer.deallocate() }

        let compressedSize = data.withUnsafeBytes { srcPtr in
            compression_encode_buffer(dstBuffer, bufferSize,
                                      srcPtr.bindMemory(to: UInt8.self).baseAddress!,
                                      data.count, nil, COMPRESSION_ZLIB)
        }

        return Data(bytes: dstBuffer, count: compressedSize)
    }

    private func startSyncServer() {
        do {
            listener = try NWListener(using: .tcp, on: 5050)
            listener?.newConnectionHandler = { connection in
                connection.start(queue: .main)
                self.connections.append(connection)
                self.receive(connection)
            }
            listener?.start(queue: .main)
        } catch {
            print("❌ Failed to start listener: \(error)")
        }
    }

    private func receive(_ connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 1_000_000) { data, _, _, _ in
            guard let data = data else { return }
            do {
                let packet = try JSONDecoder().decode(ClipboardTransferPacket.self, from: data)
                if packet.token == self.sharedToken {
                    let item = try packet.decodedClipboardItem()
                    self.insertIfNew(item: item)
                }
            } catch {
                print("❌ Receive error: \(error)")
            }
        }
    }

    func saveHistory() {
        do {
            let data = try JSONEncoder().encode(history)
            UserDefaults.standard.set(data, forKey: historyKey)
        } catch {
            print("❌ Failed to save history: \(error)")
        }
    }

    func loadHistory() {
        guard let data = UserDefaults.standard.data(forKey: historyKey) else { return }
        do {
            history = try JSONDecoder().decode([ClipboardItem].self, from: data)
        } catch {
            print("❌ Failed to load history: \(error)")
        }
    }

    func clearHistory() {
        undoStack.append(history)
        history.removeAll()
        saveHistory()
    }

    func deleteItem(id: UUID) {
        undoStack.append(history)
        history.removeAll { $0.id == id }
        saveHistory()
    }

    func undoClear() {
        guard let last = undoStack.popLast() else { return }
        history = last
        saveHistory()
    }

    func undoDelete() {
        undoClear()
    }
    
    func addPeer(host: String) {
        if !peers.contains(host) {
            peers.append(host)
        }
    }

}



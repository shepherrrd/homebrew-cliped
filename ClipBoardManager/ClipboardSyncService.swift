

import Foundation
import Network

class ClipboardSyncService {
    private let port: NWEndpoint.Port = 8888
    private var listener: NWListener?

    func startListening(monitor: ClipboardMonitor) {
        do {
            listener = try NWListener(using: .tcp, on: port)
        } catch {
            print("❌ Failed to start listener: \(error)")
            return
        }

        listener?.newConnectionHandler = { connection in
            connection.start(queue: .global())
            self.receive(on: connection, monitor: monitor)
        }

        listener?.start(queue: .global())
        print("📡 Listening for clipboard sync on port \(port)")
    }

    private func receive(on connection: NWConnection, monitor: ClipboardMonitor) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, _, _ in
            if let data = data {
                do {
                    let item = try JSONDecoder().decode(ClipboardItem.self, from: data)
                    DispatchQueue.main.async {
                        monitor.insertIfNew(item: item)
                    }
                } catch {
                    print("❌ Failed to decode sync item: \(error)")
                }
            }
        }
    }

    func broadcast(_ item: ClipboardItem, to hosts: [String]) {
        for host in hosts {
            let connection = NWConnection(host: NWEndpoint.Host(host), port: port, using: .tcp)
            connection.start(queue: .global())

            do {
                let data = try JSONEncoder().encode(item)
                connection.send(content: data, completion: .contentProcessed({ _ in
                    connection.cancel()
                }))
            } catch {
                print("❌ Failed to encode item: \(error)")
            }
        }
    }
}

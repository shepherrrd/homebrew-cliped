

import Foundation
import Network

class PeerAdvertiserService {
    private let service: NetService
    private let serviceType = "_clipboard-sync._tcp."
    private let domain = "local."

    init(port: Int) {
        let name = Host.current().localizedName ?? UUID().uuidString
        service = NetService(domain: domain, type: serviceType, name: name, port: Int32(port))
    }

    func start() {
        service.publish()
        print("📡 Service advertised via Bonjour as \(service.name).")
    }

    func stop() {
        service.stop()
    }
}

import Foundation
import Network

class PeerDiscoveryService: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, ObservableObject {
    private let serviceType = "_clipboard-sync._tcp."
    private let domain = "local."
    private let browser = NetServiceBrowser()

    @Published var discoveredPeers: [NetService] = []

    override init() {
        super.init()
        browser.delegate = self
    }

    func startBrowsing() {
        browser.searchForServices(ofType: serviceType, inDomain: domain)
    }

    func stopBrowsing() {
        browser.stop()
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        if !discoveredPeers.contains(where: { $0.name == service.name }) {
            discoveredPeers.append(service)
            print("🔍 Found peer: \(service.name)")
        }
    }

    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        discoveredPeers.removeAll { $0.name == service.name }
        print("❌ Lost peer: \(service.name)")
    }
}

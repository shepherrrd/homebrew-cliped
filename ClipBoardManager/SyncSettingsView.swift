
import SwiftUI

struct SyncSettingsView: View {
    @State private var discoveredPeers: [String] = []
    @State private var manualHost: String = ""
    @State private var token: String = ""
    @ObservedObject var discoveryService: PeerDiscoveryService
    var onPeerAdd: (String) -> Void
    
    var onPeerAdded: ((String, String) -> Void)?  // (host, token)
    var connectedPeers: [String] = []
    var sharedToken: String = "zzub-shared-key"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Enable LAN Clipboard Sync", isOn: .constant(true))
            Toggle("Enable Bonjour Discovery", isOn: .constant(true))
            
            HStack {
                Text("Shared Token")
                Spacer()
                Text(sharedToken).font(.system(size: 10)).foregroundColor(.gray)
                Button("Copy") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(sharedToken, forType: .string)
                }
            }
            
            Divider()
            
            HStack {
                TextField("host.local or 192.168.x.x", text: $manualHost)
                TextField("Token", text: $token)
                Button("Add") {
                    if !manualHost.isEmpty && !token.isEmpty {
                        onPeerAdded?(manualHost, token)
                        manualHost = ""
                        token = ""
                    }
                }
            }
            
            Text("Discovered Peers").font(.headline)

            List(discoveryService.discoveredPeers, id: \.name) { peer in
                           HStack {
                               Text(peer.name)
                               Spacer()
                               Button("Add") {
                                   peer.delegate = nil
                                   peer.resolve(withTimeout: 5.0)
                                   peer.delegate = PeerResolveDelegate(onResolved: { host in
                                       onPeerAdd(host)
                                   })
                               }
                           }
                       }
                       Spacer()
                   
                   .padding()
                   .onAppear {
                       discoveryService.startBrowsing()
                   }
                   .onDisappear {
                       discoveryService.stopBrowsing()
                   }
            
            
            
            
            Text("Discovered Peers").bold()
            ForEach(discoveredPeers, id: \.self) { peer in
                HStack {
                    Text(peer)
                    Spacer()
                    Button("Request Sync") {
                        onPeerAdded?(peer, token)
                    }
                }
            }
            
            Text("Connected Peers").bold()
            ForEach(connectedPeers, id: \.self) { peer in
                Text(peer)
            }
            
        }.padding().frame(width: 500, height: 400)
    }
}



class PeerResolveDelegate: NSObject, NetServiceDelegate {
    let onResolved: (String) -> Void

    init(onResolved: @escaping (String) -> Void) {
        self.onResolved = onResolved
    }

    func netServiceDidResolveAddress(_ sender: NetService) {
        if let addresses = sender.addresses {
            for addr in addresses {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                addr.withUnsafeBytes { rawPtr in
                    let sockaddr = rawPtr.bindMemory(to: sockaddr.self).baseAddress!
                    getnameinfo(sockaddr, socklen_t(addr.count), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST)
                }
                let ip = String(cString: hostname)
                onResolved(ip)
            }
        }
    }
}

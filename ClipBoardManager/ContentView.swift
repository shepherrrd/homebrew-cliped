import SwiftUI

struct ContentView: View {
    @ObservedObject var monitor: ClipboardMonitor

    var body: some View {
        print("🧪 UI rendering \(monitor.history.count) items")

        return ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if monitor.history.isEmpty {
                    Text("Nothing copied yet.")
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(monitor.history, id: \.self) { item in
                        Button(action: {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(item, forType: .string)
                            simulatePaste()
                            NSApp.keyWindow?.close()
                        }) {
                            Text("📋 \(item)")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                                .lineLimit(2)
                                .padding(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.yellow) // visible background
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .background(Color.white)
    }
}

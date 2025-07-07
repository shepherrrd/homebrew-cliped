import Foundation

struct ClipboardItem: Identifiable, Equatable, Codable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let device: String

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.content == rhs.content &&
        lhs.timestamp == rhs.timestamp &&
        lhs.device == rhs.device
    }
}

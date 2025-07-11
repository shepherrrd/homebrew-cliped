import Foundation
import AppKit

enum ClipboardContent: Codable, Equatable {
    case text(String)
    case image(Data)

    enum CodingKeys: String, CodingKey {
        case type, value
    }

    enum ContentType: String, Codable {
        case text, image
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let str):
            try container.encode(ContentType.text, forKey: .type)
            try container.encode(str, forKey: .value)
        case .image(let data):
            try container.encode(ContentType.image, forKey: .type)
            try container.encode(data, forKey: .value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ContentType.self, forKey: .type)
        switch type {
        case .text:
            let value = try container.decode(String.self, forKey: .value)
            self = .text(value)
        case .image:
            let value = try container.decode(Data.self, forKey: .value)
            self = .image(value)
        }
    }
}

struct ClipboardItem: Codable, Identifiable, Equatable {
    let id: UUID
    let content: ClipboardContent
    let timestamp: Date
    let device: String

    init(content: ClipboardContent, timestamp: Date, device: String) {
        self.id = UUID()
        self.content = content
        self.timestamp = timestamp
        self.device = device
    }

    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        return lhs.content == rhs.content && lhs.device == rhs.device
    }
}

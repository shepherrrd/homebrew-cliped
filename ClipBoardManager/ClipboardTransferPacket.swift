import Foundation
import Compression

struct ClipboardTransferPacket: Codable {
    let token: String
    let data: String  // Base64 encoded compressed data

    init(token: String, rawData: Data) {
        self.token = token
        self.data = rawData.base64EncodedString()
    }

    func decodedClipboardItem() throws -> ClipboardItem {
        guard let compressed = Data(base64Encoded: data) else {
            throw NSError(domain: "DecodeError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid base64"])
        }
        let decompressed = decompress(compressed)
        return try JSONDecoder().decode(ClipboardItem.self, from: decompressed)
    }

    private func decompress(_ data: Data) -> Data {
        let bufferSize = 10_000_000
        let dstBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { dstBuffer.deallocate() }

        let size = data.withUnsafeBytes { srcPtr in
            compression_decode_buffer(
                dstBuffer,
                bufferSize,
                srcPtr.bindMemory(to: UInt8.self).baseAddress!,
                data.count,
                nil,
                COMPRESSION_ZLIB
            )
        }

        return Data(bytes: dstBuffer, count: size)
    }
}

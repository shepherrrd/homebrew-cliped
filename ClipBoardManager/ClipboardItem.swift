//
//  ClipboardItem.swift
//  ClipBoardManager
//
//  Created by MAC on 07/07/2025.
//


import Foundation

struct ClipboardItem: Identifiable, Codable {
    let id = UUID()
    let content: String
    let timestamp: Date
    let deviceName: String

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

//
//  EmojiJson.swift
//  ArgumentParser
//
//  Created by Kazuya Ueoka on 2020/06/30.
//

import Foundation

struct EmojiJson: Codable {
    let ok: Bool
    let emoji: [Emoji]
}

struct Emoji: Codable {
    let name: String
    let url: URL
    let created: TimeInterval
    let userDisplayName: String
    let isAlias: UInt8
}

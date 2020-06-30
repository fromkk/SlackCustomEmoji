//
//  EmojiDownloader.swift
//  CustomEmoji
//
//  Created by Kazuya Ueoka on 2020/06/30.
//

import Foundation

final class EmojiDownloader {
    private let download: String
    private let emoji: Emoji
    init(download: String, emoji: Emoji) {
        self.download = download
        self.emoji = emoji
    }

    func perform(_ completion: @escaping (Error?) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let writeURL = URL(fileURLWithPath:  download).appendingPathComponent(emoji.name).appendingPathExtension("png")
        let task = session.dataTask(with: emoji.url) { (data, _, error) in
            defer {
                semaphore.signal()
            }

            if let error = error {
                completion(error)
                return
            }

            guard let data = data else { return }
            do {
                try data.write(to: writeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
        task.resume()
        semaphore.wait()
    }
}

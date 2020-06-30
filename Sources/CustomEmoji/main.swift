import Foundation
import ArgumentParser
import Logging

private let fileManager = FileManager.default
private let logger = Logger(label: "me.fromkk.CustomEmoji")
private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.calendar = Calendar(identifier: .gregorian)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = .current
    dateFormatter.dateFormat = "yyyyMMddHHmmss"
    return dateFormatter
}()

var downloadEmojis: [Emoji] = []

final class CustomEmoji: ParsableCommand {
    @Argument(help: "Path to custom emoji jsons.")
    var directory: String

    @Option(name: .shortAndLong, help: "UserDisplayName for filter")
    var userDisplayName: String?

    @Option(name: .shortAndLong, help: "filtering from YYYYMMDD")
    var from: String?

    @Option(name: .shortAndLong, help: "filtering to YYYYMMDD")
    var to: String?

    @Option(name: .shortAndLong, help: "path to Download directory")
    var download: String?

    enum CustomEmojiError: Error {
        case directoryNotFound(String)
        case pathIsNotDirectory
    }

    private func checkDirectoryExists() throws {
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: directory, isDirectory: &isDirectory) else {
            throw CustomEmojiError.directoryNotFound(directory)
        }
        guard isDirectory.boolValue else {
            throw CustomEmojiError.pathIsNotDirectory
        }
    }

    private func fileList() throws -> [URL] {
        return try fileManager.contentsOfDirectory(atPath: directory).filter { !$0.hasPrefix(".") }.map { URL(fileURLWithPath: directory).appendingPathComponent($0) }
    }

    private func parseJSON(of file: URL) throws -> EmojiJson {
        let data = try Data(contentsOf: file)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return try jsonDecoder.decode(EmojiJson.self, from: data)
    }

    private func makeDirectoryIfNeeded(at path: String) throws {
        guard !fileManager.fileExists(atPath: path) else { return }
        try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
    }

    private func download(at download: String, emoji: Emoji, completion: @escaping (Error?) -> Void) {
        let downloader = EmojiDownloader(download: download, emoji: emoji)
        downloader.perform(completion)
    }

    private func next(at path: String) {
        guard let emoji = downloadEmojis.popLast() else {
            logger.info("completion!")
            return
        }
        logger.info("download start \(emoji.name)")
        download(at: path, emoji: emoji) { [weak self] (error) in
            if let error = error {
                logger.error("\(error.localizedDescription)")
            } else {
                logger.info("downloaded \(emoji.name)")
            }
            self?.next(at: path)
        }
    }

    func run() throws {
        try checkDirectoryExists()
        let files = try fileList()
        let emojiJsons = try files.map { try parseJSON(of: $0) }
        let emojis = emojiJsons.reduce(into: []) { (result, json) in
            result.append(contentsOf: json.emoji)
        }

        let fromTimestamp: TimeInterval? = {
            guard let from = from else { return nil }
            return dateFormatter.date(from: from + "000000")?.timeIntervalSince1970
        }()

        let toTimestamp: TimeInterval? = {
            guard let to = to else { return nil }
            return dateFormatter.date(from: to + "235959")?.timeIntervalSince1970
        }()

        let filteredEmojis = emojis.filter { emoji in
            guard emoji.isAlias == 0 else { return false }

            if let userDisplayName = userDisplayName, emoji.userDisplayName != userDisplayName {
                return false
            }

            if let fromTimestamp = fromTimestamp, emoji.created < fromTimestamp {
                return false
            }

            if let toTimestamp = toTimestamp, emoji.created > toTimestamp {
                return false
            }

            return true
        }

        if let download = download {
            try makeDirectoryIfNeeded(at: download)
            downloadEmojis = filteredEmojis.reversed()
            next(at: download)
        }
    }
}

CustomEmoji.main()

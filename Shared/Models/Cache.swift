//
//  Cache.swift
//  Fragment
//
//  Created by Dan Hart on 3/28/22.
//

import Foundation

// swiftlint:disable all
final class Cache<Key: Codable & Hashable, Value: Codable> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()

    init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 12 * 60 * 60, maximumEntryCount: Int = 50) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }

    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
        if let filePath = try? saveToDisk(with: "\(key)") {
            print("Inserted value for \(key) at \(filePath.absoluteURL)")
        }
    }

    func value<Value: Codable>(forKey key: Key) -> Value? {
        var entry: Value?
        if let memoryEntry = wrapped.object(forKey: WrappedKey(key)) {
            entry = memoryEntry.value as? Value
        } else {
            if let diskEntry = try? readFromDisk(Value.self, with: key) {
                entry = diskEntry
            }
        }

        return entry
    }

    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

// MARK: - Cache Subscript

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

// MARK: - Cache.WrappedKey

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

// MARK: - Cache.Entry

private extension Cache {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date

        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

// MARK: - Cache.KeyTracker

private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()

        func cache(_: NSCache<AnyObject, AnyObject>,
                   willEvictObject obj: Any)
        {
            guard let entry = obj as? Entry else {
                return
            }

            keys.remove(entry.key)
        }
    }
}

// MARK: - Cache Codable

extension Cache.Entry: Codable where Key: Codable, Value: Codable {}

private extension Cache {
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

extension Cache: Codable where Key: Codable, Value: Codable {
    convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap(entry))
    }
}

// MARK: - Cache Save To Disk

extension Cache where Key: Codable & Hashable, Value: Codable {
    @discardableResult
    func saveToDisk(
        with name: String,
        using fileManager: FileManager = .default
    ) throws -> URL? {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
        return fileURL
    }

    func readFromDisk<Value: Codable>(
        _: Value.Type,
        with name: Key,
        using fileManager: FileManager = .default
    ) throws -> Value? {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent("\(name).cache")
        let data = try Data(contentsOf: fileURL)
        do {
            let cache = try JSONDecoder().decode(Cache.self, from: data)
            return cache.value(forKey: name)
        } catch {
            print(error)
            return nil
        }

        return nil
    }

    @discardableResult
    func deleteFromDisk(
        with name: String,
        using fileManager: FileManager = .default
    ) throws -> URL? {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let fileURL = folderURLs[0].appendingPathComponent(name + ".cache")
        try fileManager.removeItem(at: fileURL)
        return fileURL
    }
}

enum CacheHelper {
    @discardableResult
    static func clearAllCaches(using fileManager: FileManager = .default) -> Bool {
        let folderURLs = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )

        let folderURL = folderURLs[0]

        var didSucceed = true
        do {
            let filePaths = try fileManager.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for filePath in filePaths {
                try fileManager.removeItem(at: filePath)
            }
        } catch {
            didSucceed = false
        }

        return didSucceed
    }
}

// swiftlint:enable all

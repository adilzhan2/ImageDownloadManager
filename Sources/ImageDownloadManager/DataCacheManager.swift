//
//  DataCacheManager.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 07.02.2025.
//

import Foundation

protocol DataCacheManagerInterface {
    /// Saves data to both memory and disk cache for the given URL.
    /// - Parameters:
    ///   - data: The data to be cached.
    ///   - url: The URL associated with the data.
    func saveData(_ data: Data, for url: URL)

    /// Loads cached data for the given URL, checking memory first, then disk.
    /// - Parameter url: The URL associated with the cached data.
    /// - Returns: The cached data, or `nil` if not found.
    func loadData(for url: URL) -> Data?

    /// Clears both memory and disk caches.
    func clearCache()
}

/// Manages data caching in memory and on disk.
/// This class provides an efficient caching mechanism to store and retrieve data,
/// such as image files, by leveraging both memory and disk storage.
final class DataCacheManager: DataCacheManagerInterface {

    /// Memory cache for fast data access.
    private(set) var memoryCache = NSCache<NSURL, NSData>()

    /// File manager for handling disk operations.
    private let fileManager = FileManager.default

    /// URL pointing to the directory where cached files are stored on disk.
    private let diskCacheURL: URL

    /// Initializes the data cache manager and sets up the disk cache directory.
    init() {
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache")

        // Ensure the disk cache directory exists.
        if !fileManager.fileExists(atPath: diskCacheURL.path) {
            do {
                try fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
                Log.info("Disk cache directory created at: \(diskCacheURL.path)")
            } catch {
                Log.error("Failed to create disk cache directory: \(error.localizedDescription)")
            }
        }
    }

    /// Saves data to both memory and disk cache for the given URL.
    /// - Parameters:
    ///   - data: The data to be cached.
    ///   - url: The URL associated with the data.
    func saveData(_ data: Data, for url: URL) {
        let nsData = NSData(data: data)

        // Save to memory cache.
        memoryCache.setObject(nsData, forKey: url as NSURL)
        Log.debug("Data saved to memory cache for URL: \(url)")

        // Save to disk cache.
        let fileURL = diskCacheURL.appendingPathComponent(url.lastPathComponent)
        do {
            try nsData.write(to: fileURL)
            Log.info("Data successfully saved to disk cache for URL: \(url)")
        } catch {
            Log.error("Failed to save data to disk for URL: \(url), error: \(error.localizedDescription)")
        }
    }

    /// Loads cached data for the given URL, checking memory first, then disk.
    /// - Parameter url: The URL associated with the cached data.
    /// - Returns: The cached data, or `nil` if not found.
    func loadData(for url: URL) -> Data? {
        // Attempt to load from memory cache.
        if let cachedData = memoryCache.object(forKey: url as NSURL) {
            Log.debug("Loaded data from memory cache for URL: \(url)")
            return cachedData as Data
        }

        // Attempt to load from disk cache.
        let fileURL = diskCacheURL.appendingPathComponent(url.lastPathComponent)
        do {
            let diskData = try Data(contentsOf: fileURL)
            memoryCache.setObject(diskData as NSData, forKey: url as NSURL)
            Log.info("Loaded data from disk cache and added to memory for URL: \(url)")
            return diskData
        } catch {
            Log.debug("No data available in disk cache for URL: \(url)")
        }

        return nil
    }

    /// Clears both memory and disk caches.
    func clearCache() {
        // Clear memory cache.
        memoryCache.removeAllObjects()
        Log.info("Memory cache cleared")

        // Clear disk cache by removing and recreating the directory.
        do {
            try fileManager.removeItem(at: diskCacheURL)
            try fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
            Log.info("Disk cache cleared and directory recreated")
        } catch {
            Log.error("Failed to clear disk cache: \(error.localizedDescription)")
        }
    }
}

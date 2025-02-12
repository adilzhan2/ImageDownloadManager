//
//  DataCacheManagerTests.swift
//
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import XCTest
@testable import ImageDownloadManager

final class DataCacheManagerTests: XCTestCase {

    var cacheManager: DataCacheManager!
    var testURL: URL!
    var testData: Data!

    override func setUp() {
        super.setUp()
        cacheManager = DataCacheManager()
        testURL = URL(string: "https://example.com/image.jpg")!
        testData = "TestData".data(using: .utf8)
    }

    override func tearDown() {
        cacheManager.clearCache()
        cacheManager = nil
        testURL = nil
        testData = nil
        super.tearDown()
    }

    func testSaveDataToMemoryCache() {
        cacheManager.saveData(testData, for: testURL)

        let retrievedData = cacheManager.loadData(for: testURL)

        XCTAssertNotNil(retrievedData, "Data should be stored in memory cache")
        XCTAssertEqual(retrievedData, testData, "Retrieved data should match the saved data")
    }

    func testSaveDataToDiskCache() {
        cacheManager.saveData(testData, for: testURL)

        // Удаляем из памяти, чтобы проверить загрузку с диска
        cacheManager.memoryCache.removeAllObjects()

        let retrievedData = cacheManager.loadData(for: testURL)

        XCTAssertNotNil(retrievedData, "Data should be loaded from disk cache")
        XCTAssertEqual(retrievedData, testData, "Retrieved data from disk should match the saved data")
    }

    func testLoadData_NotCached() {
        let retrievedData = cacheManager.loadData(for: testURL)
        XCTAssertNil(retrievedData, "Data should be nil for non-cached URL")
    }

    func testClearCache() {
        cacheManager.saveData(testData, for: testURL)

        cacheManager.clearCache()

        let retrievedData = cacheManager.loadData(for: testURL)
        XCTAssertNil(retrievedData, "Cache should be empty after clearing")
    }
}

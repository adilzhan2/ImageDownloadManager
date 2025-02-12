//
//  ImageTaskManagerTests.swift
//
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import XCTest
@testable import ImageDownloadManager

final class ImageTaskManagerTests: XCTestCase {

    func testImageDownloadingInfoProgressAndCompletion() async {
        let expectation = XCTestExpectation(description: "Completion handler should be called")

        var progressUpdates: [Double] = []
        let expectedFinalResult = "downloaded_file_path"

        let downloadingInfo = ImageDownloadingInfo(
            progressHandler: { progress in
                progressUpdates.append(progress)
            },
            completionHandler: { result in
                switch result {
                case .success(let filePath):
                    XCTAssertEqual(filePath, expectedFinalResult, "Completion should return the expected file path")
                case .failure:
                    XCTFail("Completion should not fail")
                }
                expectation.fulfill()
            }
        )

        // Simulating progress updates
        await downloadingInfo.progressHandler?(0.1)
        await downloadingInfo.progressHandler?(0.5)
        await downloadingInfo.progressHandler?(1.0)

        // Simulating completion
        await downloadingInfo.completionHandler(.success(expectedFinalResult))

        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(progressUpdates.isEmpty, "Progress handler should receive updates")
        XCTAssertEqual(progressUpdates, [0.1, 0.5, 1.0], "Progress updates should be correctly captured")
    }

    func testAddAndRetrieveTask() async {
        let taskManager = ImageTaskManager()
        let url = URL(string: "https://example.com/image.jpg")!
        let mockTask = URLSessionDownloadTask() // Это заглушка, в реальных тестах используйте моки

        let downloadingInfo = ImageDownloadingInfo(completionHandler: { _ in })

        await taskManager.addTask(mockTask, for: url, info: downloadingInfo)

        let retrievedTask = await taskManager.getTask(for: url)
        let retrievedInfo = await taskManager.getDownloadingInfo(for: url)

        XCTAssertNotNil(retrievedTask, "Task should be retrievable after adding")
        XCTAssertNotNil(retrievedInfo, "Downloading info should be retrievable after adding")
    }

    func testRemoveTask() async {
        let taskManager = ImageTaskManager()
        let url = URL(string: "https://example.com/image.jpg")!
        let mockTask = URLSessionDownloadTask()
        let downloadingInfo = ImageDownloadingInfo(completionHandler: { _ in })

        await taskManager.addTask(mockTask, for: url, info: downloadingInfo)
        await taskManager.removeTask(for: url)

        let retrievedTask = await taskManager.getTask(for: url)
        let retrievedInfo = await taskManager.getDownloadingInfo(for: url)

        XCTAssertNil(retrievedTask, "Task should be removed successfully")
        XCTAssertNil(retrievedInfo, "Downloading info should be removed successfully")
    }
}

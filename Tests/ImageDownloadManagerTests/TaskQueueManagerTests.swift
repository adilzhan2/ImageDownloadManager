//
//  TaskQueueManagerTests.swift
//
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import XCTest
@testable import ImageDownloadManager

final class TaskQueueManagerTests: XCTestCase {

    var taskQueueManager: TaskQueueManager!

    override func setUp() {
        super.setUp()
        taskQueueManager = TaskQueueManager()
    }

    override func tearDown() {
        taskQueueManager = nil
        super.tearDown()
    }

    func testTaskExecution() {
        let expectation = XCTestExpectation(description: "Task should execute")

        taskQueueManager.execute {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testMultipleTasksExecution() {
        let taskCount = 5
        let expectation = XCTestExpectation(description: "All tasks should execute")
        expectation.expectedFulfillmentCount = taskCount

        for _ in 0..<taskCount {
            taskQueueManager.execute {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testConcurrencyLimit() {
        let maxConcurrentOperations = ProcessInfo.processInfo.activeProcessorCount
        let semaphore = DispatchSemaphore(value: 0)
        let expectation = XCTestExpectation(description: "Tasks should not exceed concurrency limit")
        expectation.expectedFulfillmentCount = maxConcurrentOperations

        for _ in 0..<maxConcurrentOperations {
            taskQueueManager.execute {
                expectation.fulfill()
                semaphore.wait() // Simulating a long-running task
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }
}


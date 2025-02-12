//
//  TaskQueueManager.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 07.02.2025.
//

import Foundation

protocol TaskQueueManagerInterface {
    /// Executes a given task concurrently while respecting resource limitations.
    /// - Parameter task: The task to be executed.
    func execute(task: @escaping () -> Void)
}

/// Manages a queue for handling concurrent tasks with a limited number of parallel operations.
final class TaskQueueManager: TaskQueueManagerInterface {

    /// Operation queue responsible for managing concurrent download tasks.
    private let downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "ImageDownloadQueue"
        queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount // Limit the number of parallel downloads
        queue.qualityOfService = .background
        return queue
    }()

    /// Initializes the task queue manager.
    init() {
        Log.info("TaskQueueManager initialized with maxConcurrentOperationCount: \(downloadQueue.maxConcurrentOperationCount)")
    }

    /// Executes a given task concurrently while respecting resource limitations.
    /// - Parameter task: The task to be executed.
    func execute(task: @escaping () -> Void) {
        Log.debug("Adding a new task to the queue. Current queue size: \(downloadQueue.operationCount)")
        downloadQueue.addOperation {
            Log.info("Executing a task in TaskQueueManager. Remaining tasks: \(self.downloadQueue.operationCount - 1)")
            task()
        }
    }
}

//
//  ImageTaskManager.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 09.02.2025.
//

import Foundation

/// Defines the required functionality for managing image download tasks.
protocol ImageTaskManagerInterface {
    /// Adds a download task to the manager.
    /// - Parameters:
    ///   - task: The URLSession download task to add.
    ///   - url: The URL associated with the download task.
    ///   - info: Information about the download progress and completion.
    func addTask(_ task: URLSessionDownloadTask, for url: URL, info: ImageDownloadingInfo) async

    /// Retrieves the active download task for a given URL.
    /// - Parameter url: The URL of the image being downloaded.
    /// - Returns: The associated `URLSessionDownloadTask` if a task exists, otherwise `nil`.
    func getTask(for url: URL) async -> URLSessionDownloadTask?

    /// Retrieves the download information for a given URL.
    /// - Parameter url: The URL of the image being downloaded.
    /// - Returns: The associated `ImageDownloadingInfo` if available, otherwise `nil`.
    func getDownloadingInfo(for url: URL) async -> ImageDownloadingInfo?

    /// Removes the download task associated with a specific URL.
    /// - Parameter url: The URL of the task to remove.
    func removeTask(for url: URL) async

    /// Saves the resume data for an image download.
    /// - Parameters:
    ///   - data: The partially downloaded image data.
    ///   - url: The URL of the image.
    ///   - info: Downloading information containing request parameters.
    func saveResumeData(_ data: Data, for url: URL, info: ImageDownloadingInfo) async

    /// Retrieves the saved resume data for an image download.
    /// - Parameter url: The URL of the image.
    /// - Returns: The resume data if available, otherwise `nil`.
    func getResumeData(for url: URL) async -> Data?

    /// Retrieves the downloading information for resuming an image download.
    /// - Parameter url: The URL of the image.
    /// - Returns: The downloading information if available, otherwise `nil`.
    func getResumeDownloadingInfo(for url: URL) async -> ImageDownloadingInfo?
}

/// Manages active image download tasks and handles task state management.
actor ImageTaskManager: ImageTaskManagerInterface {
    /// Dictionary storing active tasks with their associated download information.
    private var activeTasks: [URL: (URLSessionDownloadTask, ImageDownloadingInfo)] = [:]

    /// Dictionary storing resume data for paused downloads.
    private var resumeDataStore: [URL: (Data, ImageDownloadingInfo)] = [:]

    /// Adds a download task to the manager.
    /// - Parameters:
    ///   - task: The URLSession download task to add.
    ///   - url: The URL associated with the download task.
    ///   - info: Information about the download progress and completion.
    func addTask(_ task: URLSessionDownloadTask, for url: URL, info: ImageDownloadingInfo) {
        activeTasks[url] = (task, info)
        Log.info("Task added for URL: \(url)")
    }

    /// Retrieves the active download task for a given URL.
    /// - Parameter url: The URL of the image being downloaded.
    /// - Returns: The associated `URLSessionDownloadTask` if a task exists, otherwise `nil`.
    func getTask(for url: URL) -> URLSessionDownloadTask? {
        if let (task, _) = activeTasks[url] {
            Log.debug("Task retrieved for URL: \(url)")
            return task
        } else {
            Log.debug("No task found for URL: \(url)")
            return nil
        }
    }

    /// Retrieves the download information for a given URL.
    /// - Parameter url: The URL of the image being downloaded.
    /// - Returns: The associated `ImageDownloadingInfo` if available, otherwise `nil`.
    func getDownloadingInfo(for url: URL) -> ImageDownloadingInfo? {
        if let (_, downloadingInfo) = activeTasks[url] {
            Log.debug("Downloading info retrieved for URL: \(url)")
            return downloadingInfo
        } else {
            Log.debug("No downloading info found for URL: \(url)")
            return nil
        }
    }

    /// Removes the download task associated with a specific URL.
    /// - Parameter url: The URL of the task to remove.
    func removeTask(for url: URL) {
        if activeTasks.removeValue(forKey: url) != nil {
            Log.info("Task removed for URL: \(url)")
        } else {
            Log.debug("No task to remove for URL: \(url)")
        }
    }

    /// Saves the resume data for an image download.
    /// - Parameters:
    ///   - data: The partially downloaded image data.
    ///   - url: The URL of the image.
    ///   - info: Downloading information containing request parameters.
    func saveResumeData(_ data: Data, for url: URL, info: ImageDownloadingInfo) {
        resumeDataStore[url] = (data, info)
    }

    /// Retrieves the saved resume data for an image download.
    /// - Parameter url: The URL of the image.
    /// - Returns: The resume data if available, otherwise `nil`.
    func getResumeData(for url: URL) -> Data? {
        if let (data, _) = resumeDataStore[url] {
            Log.debug("Data retrieved for URL: \(url)")
            return data
        } else {
            Log.debug("No data found for URL: \(url)")
            return nil
        }
    }

    /// Retrieves the downloading information for resuming an image download.
    /// - Parameter url: The URL of the image.
    /// - Returns: The downloading information if available, otherwise `nil`.
    func getResumeDownloadingInfo(for url: URL) -> ImageDownloadingInfo? {
        if let (_, downloadingInfo) = resumeDataStore[url] {
            Log.debug("Downloading info retrieved for URL: \(url)")
            return downloadingInfo
        } else {
            Log.debug("No downloading info found for URL: \(url)")
            return nil
        }
    }
}

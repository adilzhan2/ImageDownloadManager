//
//  ImageLoader.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 08.02.2025.
//

import UIKit
import Foundation

/// Protocol defining the image download management functionality.
protocol ImageDownloadManagerInterface {
    /// Downloads an image from the specified URL.
    /// - Parameters:
    ///   - url: The URL to download the image from.
    ///   - progressHandler: A closure called with download progress updates (from 0.0 to 1.0).
    /// - Returns: The downloaded image as a `UIImage`.
    /// - Throws: An error if the download fails.
    func downloadImage(from url: URL, progressHandler: ((Double) -> Void)?) async throws -> UIImage

    /// Cancels an ongoing download for the given URL.
    /// - Parameter url: The URL whose download should be canceled.
    func cancelDownload(for url: URL)

    /// Resumes a previously paused download for the given URL.
    /// If resume data is available, the download continues from where it left off.
    /// Otherwise, a new download is started.
    /// - Parameter url: The URL of the image to resume downloading.
    func resumeDownload(for url: URL)
    
    /// Pauses an ongoing download for the given URL and saves resume data.
    /// If the download task is found, it is canceled with resume data.
    /// The resume data is then stored for future use.
    /// - Parameter url: The URL of the image download to pause.
    func pauseDownload(for url: URL)
}

/// A manager responsible for handling image downloads, including caching and task management.
public final class ImageDownloadManager: NSObject, URLSessionDownloadDelegate, ImageDownloadManagerInterface {
    /// Manages image download tasks and their associated data.
    private let taskManager: ImageTaskManagerInterface = ImageTaskManager()
    private let dataCacheManager: DataCacheManagerInterface = DataCacheManager()
    private let downloadQueue: TaskQueueManagerInterface = TaskQueueManager()

    /// A URL session configured with a custom delegate.
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    /// Singleton instance for shared use of `ImageDownloadManager`.
    static var shared: ImageDownloadManagerInterface = ImageDownloadManager()

    /// Private initializer to enforce singleton usage.
    private override init() { }

    /// Downloads an image from the specified URL, with optional progress tracking.
    /// - Parameters:
    ///   - url: The URL to download the image from.
    ///   - progressHandler: A closure called with download progress updates (optional).
    /// - Returns: The downloaded image as a `UIImage`.
    /// - Throws: An error if the download fails.
    func downloadImage(from url: URL, progressHandler: ((Double) -> Void)? = nil) async throws -> UIImage {
        Log.info("Starting download for URL: \(url.absoluteString)")

        // Check in data cache first
        if let cachedData = dataCacheManager.loadData(for: url), let image = UIImage(data: cachedData) {
            Log.info("Image found in cache for URL: \(url.absoluteString)")
            progressHandler?(1)
            return image
        }

        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.downloadQueue.execute(task: { [weak self] in
                guard let self else {
                    let error = ImageDownloadError.networkError(NSError(domain: "ImageDownload", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))
                    Log.error("Failed to start download: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }

                let downloadInfo = ImageDownloadingInfo(progressHandler: progressHandler) { result in
                    switch result {
                    case .success(let filePath):
                        if let image = UIImage(contentsOfFile: filePath) {
                            if let imageData = image.pngData() {
                                self.dataCacheManager.saveData(imageData, for: url)
                            }
                            Log.info("Image successfully downloaded and cached for URL: \(url.absoluteString)")
                            continuation.resume(returning: image)
                        } else {
                            Log.error("Invalid image data for URL: \(url.absoluteString)")
                            continuation.resume(throwing: ImageDownloadError.invalidImageData)
                        }
                    case .failure(let error):
                        Log.error("Invalid image data for URL: \(error)")
                        continuation.resume(throwing: error)
                    }
                }

                let task = self.urlSession.downloadTask(with: url)
                task.taskDescription = url.absoluteString
                Task { [weak self] in
                    await self?.taskManager.addTask(task, for: url, info: downloadInfo)
                    Log.debug("Download task added for URL: \(url.absoluteString)")
                    task.resume()
                }
            })
        }
    }

    /// Cancels the download task for the given URL if it exists.
    /// - Parameter url: The URL whose download task should be canceled.
    func cancelDownload(for url: URL) {
        Task {
            await taskManager.getTask(for: url)?.cancel()
            Log.info("Download canceled for URL: \(url)")
            await taskManager.removeTask(for: url)
        }
    }

    /// Resumes a previously paused download for the given URL.
    /// If resume data is available, the download continues from where it left off.
    /// Otherwise, a new download is started.
    /// - Parameter url: The URL of the image to resume downloading.
    func resumeDownload(for url: URL) {
        Task {
            if let resumeData = await taskManager.getResumeData(for: url) {
                Log.info("Resuming download for URL: \(url.absoluteString)")

                let task = urlSession.downloadTask(withResumeData: resumeData)
                task.taskDescription = url.absoluteString
                if let downloadingInfo = await taskManager.getDownloadingInfo(for: url) {
                    await taskManager.addTask(task, for: url, info: downloadingInfo)
                    task.resume()
                }
            } else {
                Log.info("No resume data found, restarting download for URL: \(url.absoluteString)")
                do {
                    let _ = try await downloadImage(from: url)
                } catch {
                    Log.error("Failed to restart download for URL: \(url.absoluteString) - \(error)")
                }
            }
        }
    }

    /// Pauses an ongoing download for the given URL and saves resume data.
    /// If the download task is found, it is canceled with resume data.
    /// The resume data is then stored for future use.
    /// - Parameter url: The URL of the image download to pause.
    func pauseDownload(for url: URL) {
        Task {
            guard let task = await taskManager.getTask(for: url),
                  let downloadingInfo = await taskManager.getDownloadingInfo(for: url) else {
                Log.debug("No active download found to pause for URL: \(url.absoluteString)")
                return
            }

            let resumeData = await withCheckedContinuation { continuation in
                task.cancel { data in
                    continuation.resume(returning: data)
                }
            }

            guard let resumeData else {
                Log.error("Failed to get resume data for URL: \(url.absoluteString)")
                return
            }

            await taskManager.saveResumeData(resumeData, for: url, info: downloadingInfo)
            Log.info("Download paused and resume data saved for URL: \(url.absoluteString)")
        }
    }

    // MARK: - URLSessionDownloadDelegate

    /// Called periodically during a download to report progress.
    /// - Parameters:
    ///   - session: The session containing the download task.
    ///   - downloadTask: The task being downloaded.
    ///   - bytesWritten: Number of bytes written in this call.
    ///   - totalBytesWritten: Total bytes written so far.
    ///   - totalBytesExpectedToWrite: Expected total bytes for the task.
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        Task.detached { [weak self] in
            guard let self else { return }
            guard let urlString = downloadTask.taskDescription, let url = URL(string: urlString) else {
                Log.error("Failed to retrieve task description for progress update.")
                return
            }

            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            Log.debug("Download progress for URL \(url.absoluteString): \(progress * 100)%")
            await self.taskManager.getDownloadingInfo(for: url)?.progressHandler?(progress)
        }
    }

    /// Called when a download task finishes downloading the file to a location.
    /// - Parameters:
    ///   - session: The session containing the download task.
    ///   - downloadTask: The task that finished downloading.
    ///   - location: The location where the downloaded file is temporarily stored.
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        Log.info("Download finished for task: \(downloadTask.taskDescription ?? "Unknown")")
        Log.debug("Downloaded file path: \(location.path)")

        guard let urlString = downloadTask.taskDescription, let url = URL(string: urlString) else {
            Log.error("Failed to retrieve task description for completion handler.")
            return
        }

        let destinationURL = getDestinationURL(for: location)
        do {
            try FileManager.default.moveItem(at: location, to: destinationURL)
            Log.info("File successfully moved to: \(destinationURL.path)")
            Task.detached { [weak self] in
                guard let self else { return }
                await self.taskManager.getDownloadingInfo(for: url)?.completionHandler(.success(destinationURL.path))
                await self.taskManager.removeTask(for: url)
            }
        } catch {
            Log.error("Error saving file: \(error.localizedDescription)")
            Task.detached { [weak self] in
                guard let self else { return }
                await self.taskManager.getDownloadingInfo(for: url)?.completionHandler(.failure(ImageDownloadError.fileSaveError(error)))
                await self.taskManager.removeTask(for: url)
                Log.error("File save error for URL \(url.absoluteString)")
            }
        }
    }

    /// Generates a destination URL for a downloaded file in the document directory.
    /// - Parameter location: The temporary location of the downloaded file.
    /// - Returns: A destination URL for the file in the document directory.
    private func getDestinationURL(for location: URL) -> URL {
        let fileName = UUID().uuidString + ".tmp"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }
}

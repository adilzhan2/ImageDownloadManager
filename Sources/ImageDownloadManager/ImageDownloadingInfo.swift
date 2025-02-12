//
//  ImageDownloadingInfo.swift
//  
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import Foundation

/// Handles the download progress and completion for an image download task.
actor ImageDownloadingInfo {
    /// Closure to handle the progress of the download, providing a percentage value.
    var progressHandler: ((Double) -> Void)?

    /// Closure to handle the completion of the download, returning either a success or failure.
    var completionHandler: ((Result<String, Error>) -> Void)

    /// Initializes a new instance of `ImageDownloadingInfo`.
    /// - Parameters:
    ///   - progressHandler: A closure to handle download progress updates.
    ///   - completionHandler: A closure to handle download completion.
    init(progressHandler: ((Double) -> Void)? = nil, completionHandler: @escaping ((Result<String, Error>) -> Void)) {
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
    }
}

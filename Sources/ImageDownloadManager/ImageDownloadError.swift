//
//  ImageDownloadError.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 11.02.2025.
//

import Foundation

/// An enumeration that defines various errors that can occur during image download operations.
/// Conforms to `Error` and `LocalizedError` protocols for custom error handling and descriptions.
enum ImageDownloadError: Error, LocalizedError, Equatable {

    /// The provided URL is invalid or cannot be created.
    case invalidURL

    /// A network-related error occurred during the download.
    /// - Associated Value: The underlying network error.
    case networkError(Error)

    /// The downloaded data does not represent a valid image.
    case invalidImageData

    /// The download operation was cancelled before completion.
    case downloadCancelled

    /// An error occurred while attempting to save the downloaded image to disk.
    /// - Associated Value: The underlying file save error.
    case fileSaveError(Error)

    /// A user-friendly description of each error case.
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL provided." // Message for an invalid URL error.
        case .networkError(let error):
            return "Network error occurred: \(error.localizedDescription)" // Include details from the underlying network error.
        case .invalidImageData:
            return "Invalid image data received." // Message for invalid image data.
        case .downloadCancelled:
            return "Download was cancelled." // Message for a cancelled download.
        case .fileSaveError(let error):
            return "Failed to save image to disk: \(error.localizedDescription)" // Include details from the file save error.
        }
    }

    // Conformance to Equatable
    static func == (lhs: ImageDownloadError, rhs: ImageDownloadError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidImageData, .invalidImageData),
             (.downloadCancelled, .downloadCancelled):
            return true
        case (.networkError, .networkError),
             (.fileSaveError, .fileSaveError):
            return false // Cannot compare associated Error values directly
        default:
            return false
        }
    }
}

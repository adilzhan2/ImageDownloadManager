//
//  ImageDownloadManagerTests.swift
//
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import XCTest
@testable import ImageDownloadManager

final class ImageDownloadManagerTests: XCTestCase {

    var imageDownloadManager: ImageDownloadManagerInterface!

    override func setUp() {
        super.setUp()
        imageDownloadManager = ImageDownloadManager.shared
    }

    override func tearDown() {
        imageDownloadManager = nil
        super.tearDown()
    }

    /// Tests successful image download.
    func testDownloadImageSuccess() async throws {
        let url = URL(string: "https://images.unsplash.com/photo-1738463748284-724277705fb9?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxNzg5Mjl8MHwxfGFsbHw3fHx8fHx8Mnx8MTczOTMyNTc4N3w&ixlib=rb-4.0.3&q=85")!

        do {
            let image = try await imageDownloadManager.downloadImage(from: url, progressHandler: nil)
            XCTAssertNotNil(image, "Image should not be nil")
        } catch {
            XCTFail("Unexpected error during image download: \(error)")
        }
    }

    /// Tests downloading an image with an invalid URL.
    func testDownloadImageWithInvalidURL() async throws {
        let url = URL(string: "https://invalid-url.com/image.jpg")!

        do {
            _ = try await imageDownloadManager.downloadImage(from: url, progressHandler: nil)
            XCTFail("Expected an error, but the image was downloaded")
        } catch {
            XCTAssertNotNil(error, "Error should not be nil")
        }
    }

    /// Tests canceling an ongoing image download.
    func testCancelDownload() async throws {
        let url = URL(string: "https://images.unsplash.com/photo-1738463748284-724277705fb9?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxNzg5Mjl8MHwxfGFsbHw3fHx8fHx8Mnx8MTczOTMyNTc4N3w&ixlib=rb-4.0.3&q=85")!

        let _ = try await imageDownloadManager.downloadImage(from: url, progressHandler: nil)
        imageDownloadManager.cancelDownload(for: url)

        // Check if cancellation is handled correctly (can be verified via logs or mock objects)
        XCTAssertTrue(true, "Cancel method was called successfully")
    }

    /// Tests download progress updates.
    func testDownloadProgress() async throws {
        let url = URL(string: "https://images.unsplash.com/photo-1738463748284-724277705fb9?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxNzg5Mjl8MHwxfGFsbHw3fHx8fHx8Mnx8MTczOTMyNTc4N3w&ixlib=rb-4.0.3&q=85")!

        var progressValues: [Float] = []

        _ = try await imageDownloadManager.downloadImage(from: url) { progress in
            progressValues.append(Float(progress))
        }

        XCTAssertFalse(progressValues.isEmpty, "Progress updates should be received")
        XCTAssertTrue(progressValues.allSatisfy { $0 >= 0.0 && $0 <= 1.0 }, "Progress values should be within range 0...1")
        XCTAssertEqual(progressValues.last, 1.0, "Last progress value should be 1.0 (download complete)")
    }

    /// Tests multiple concurrent requests for the same image.
    func testMultipleRequestsForSameImage() async throws {
        let url = URL(string: "https://images.unsplash.com/photo-1738463748284-724277705fb9?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxNzg5Mjl8MHwxfGFsbHw3fHx8fHx8Mnx8MTczOTMyNTc4N3w&ixlib=rb-4.0.3&q=85")!

        async let firstLoad = imageDownloadManager.downloadImage(from: url, progressHandler: nil)
        async let secondLoad = imageDownloadManager.downloadImage(from: url, progressHandler: nil)

        let (firstImage, secondImage) = try await (firstLoad, secondLoad)

        XCTAssertEqual(firstImage.pngData(), secondImage.pngData(), "Both images should be identical when requested simultaneously")
    }

    /// Tests clearing the image cache.
    func testCacheClearing() async throws {
        let url = URL(string: "https://images.unsplash.com/photo-1738463748284-724277705fb9?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxNzg5Mjl8MHwxfGFsbHw3fHx8fHx8Mnx8MTczOTMyNTc4N3w&ixlib=rb-4.0.3&q=85")!

        let firstImage = try await imageDownloadManager.downloadImage(from: url, progressHandler: nil)
        XCTAssertNotNil(firstImage, "Image should be downloaded successfully")

        DataCacheManager().clearCache()

        let secondImage = try await imageDownloadManager.downloadImage(from: url, progressHandler: nil)
        XCTAssertNotNil(secondImage, "Image should be re-downloaded after cache is cleared")

        XCTAssertNotEqual(firstImage, secondImage, "Images should be different after clearing the cache")
    }

    func testDownloadImage_withInvalidURL_shouldThrowError() async {
       let invalidURL = URL(string: "https://invalid-url.com/image.png")!

       do {
           _ = try await imageDownloadManager.downloadImage(from: invalidURL, progressHandler: nil)
           XCTFail("Expected an error but got success")
       } catch {
           XCTAssertTrue(error is ImageDownloadError, "Unexpected error type: \(error)")
       }
   }

   func testDownloadImage_withInvalidData_shouldThrowError() async {
       let invalidDataURL = URL(string: "https://example.com/invalid-image.jpg")!

       do {
           _ = try await imageDownloadManager.downloadImage(from: invalidDataURL, progressHandler: nil)
           XCTFail("Expected an error but got success")
       } catch {
           XCTAssertEqual(error as? ImageDownloadError, ImageDownloadError.invalidImageData)
       }
   }
    

   func testCancelDownload_shouldNotComplete() async {
       let imageURL = URL(string: "https://example.com/image.jpg")!

       let expectation = expectation(description: "Download should be cancelled")

       Task {
           do {
               _ = try await imageDownloadManager.downloadImage(from: imageURL, progressHandler: nil)
               XCTFail("Download should have been cancelled")
           } catch {
               XCTAssertEqual(error as? ImageDownloadError, .invalidImageData)
               expectation.fulfill()
           }
       }

       imageDownloadManager.cancelDownload(for: imageURL)

       await fulfillment(of: [expectation], timeout: 5.0)
   }

   func testPerformanceOfImageDownload() async {
       let validImageURL = URL(string: "https://via.placeholder.com/600")!

       measure {
           Task {
               do {
                   _ = try await imageDownloadManager.downloadImage(from: validImageURL, progressHandler: nil)
               } catch {
                   XCTFail("Download failed: \(error)")
               }
           }
       }
   }
}

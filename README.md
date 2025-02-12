# ImageDownloadManager

![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![iOS](https://img.shields.io/badge/iOS-15%2B-blue.svg)

## Overview

**ImageDownloadManager** is a high-performance, multithreaded image downloading and caching framework for iOS, written in Swift. It efficiently handles image downloads with support for caching, pausing, resuming, progress tracking, and task management while ensuring optimal performance.

## Features

- Asynchronous image downloading with a multithreaded architecture
- Automatic caching to reduce redundant network requests
- Thread-safe implementation with a task management system
- Supports pausing, resuming, and canceling downloads
- Real-time download progress tracking with UI updates
- Error handling for network failures, invalid URLs, and storage issues
- Logging mechanism for debugging and error tracking

## Installation

### Swift Package Manager (SPM)

To integrate **ImageDownloadManager** using Swift Package Manager, add the following dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/adilzhan2/ImageDownloadManager.git", from: "1.0.1")
```

Or, in Xcode:

1. Go to **File > Swift Packages > Add Package Dependency**.
2. Enter the repository URL: `https://github.com/adilzhan2/ImageDownloadManager.git`
3. Choose the latest stable version and add it to your project.

## Usage

### Basic Example

```swift
import ImageDownloadManager

let url = URL(string: "https://example.com/image.jpg")!
let downloadedImage = try await ImageDownloadManager.shared.downloadImage(from: url) { progress in
    Task { @MainActor [weak self] in
        guard let self = self else { return }
        if !self.isPaused {  // Update progress only if not paused
            self.loadingProgress = progress
        }
    }
}

await MainActor.run { [weak self] in
    self?.image = downloadedImage
    self?.isLoading = false
}
```

### Pausing and Resuming a Download

```swift
ImageDownloadManager.shared.pauseDownload(for: url)
ImageDownloadManager.shared.resumeDownload(for: url)
```

### Cancelling a Download

```swift
ImageDownloadManager.shared.cancelDownload(for: url)
```

### Tracking Download Progress

```swift
let downloadedImage = try await ImageDownloadManager.shared.downloadImage(from: url) { progress in
    Task { @MainActor [weak self] in
        self?.loadingProgress = progress
    }
}
```

### Error Handling

```swift
ImageDownloadManager.shared.downloadImage(from: url, completion: { result in
    switch result {
    case .success(let image):
        imageView.image = image
    case .failure(let error):
        print("Download failed: \(error.localizedDescription)")
    }
})
```

### Clearing Cache

```swift
ImageDownloadManager.shared.clearCache()
```

## Testing

- Includes unit tests for core functionality
- Tests for error handling and performance evaluation

## Example Application

A sample app demonstrating the framework’s features is included in the repository.


## Contributing

Contributions are welcome! Please open an issue or submit a pull request to improve this library.

## Author

[Адильжан](https://github.com/adilzhan2)






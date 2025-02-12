//
//  ImageLoaderViewModel.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import SwiftUI
import ImageDownloadManager

public final class ImageLoaderViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var loadingProgress: Double = 0.0
    @Published var isLoading: Bool = false
    @Published var isPaused: Bool = false 

    private var currentURL: URL?

    init() { }

    func fetchImage(url: String) async {
        await MainActor.run {
            self.isLoading = true
            self.isPaused = false  // Сбрасываем паузу при новой загрузке
        }

        guard let url = URL(string: url) else { return }
        currentURL = url

        do {
            try await downloadImage(from: url)
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }

    private func downloadImage(from url: URL) async throws {
        try await withCheckedThrowingContinuation { continuation in
            Task.detached { [weak self] in
                do {
                    let downloadedImage = try await ImageDownloadManager.shared.downloadImage(from: url) { progress in
                        Task { @MainActor [weak self] in
                            guard let self = self else { return }
                            if !self.isPaused {  // Обновляем прогресс только если не на паузе
                                self.loadingProgress = progress
                            }
                        }
                    }

                    await MainActor.run { [weak self] in
                        self?.image = downloadedImage
                        self?.isLoading = false
                    }
                    continuation.resume()
                } catch {
                    await MainActor.run { [weak self] in
                        self?.isLoading = false
                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func cancelLoading(url: String) {
        guard let currentURL = currentURL else { return }
        ImageDownloadManager.shared.cancelDownload(for: currentURL)
        Task { @MainActor in
            self.loadingProgress = 0
            self.isPaused = false
        }
    }

    func pauseLoading() {
        guard let currentURL = currentURL else { return }
        isPaused = true
        ImageDownloadManager.shared.pauseDownload(for: currentURL)
    }

    func resumeLoading() {
        guard let currentURL = currentURL else { return }
        isPaused = false
        ImageDownloadManager.shared.resumeDownload(for: currentURL)
    }

    func togglePause() {
        isPaused ? resumeLoading() : pauseLoading()
    }
}

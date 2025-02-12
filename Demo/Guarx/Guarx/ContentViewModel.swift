//
//  ContentViewModel.swift
//  Guarx
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import Foundation

class ContentViewModel: ObservableObject {
    @Published var photos: [HomeImage] = []
    @Published var isLoading = false
    private var currentPage = 1

    func loadInitialPhotos() {
        guard photos.isEmpty else { return }
        fetchPhotos(page: currentPage)
    }

    func loadMorePhotos() {
        guard !isLoading else { return }
        fetchPhotos(page: currentPage)
    }

    private func fetchPhotos(page: Int) {
        isLoading = true
        guard let url = URL(string: "https://api.unsplash.com/photos?client_id=jRBzm2zUw2eoIPSHZxLvY_hnSh0P8J91P2THDay4y8w&order_by=latest&page=\(page)&per_page=20") else {
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let data = data {
                    do {
                        let decodedData = try JSONDecoder().decode([HomeImage].self, from: data)
                        self?.photos.append(contentsOf: decodedData)
                        self?.currentPage += 1
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
            }
        }.resume()
    }
}

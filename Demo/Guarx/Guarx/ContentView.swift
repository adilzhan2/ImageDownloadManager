//
//  ContentView.swift
//  Guarx
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 8), count: 1)

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading && viewModel.photos.isEmpty {
                    ProgressView("Loading photos...")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(viewModel.photos) { photo in
                                ImageLoader(imageUrl: photo.urls?.full ?? "")
                                    .aspectRatio(contentMode: .fill)
                                    .clipped()
                                    .cornerRadius(8)
                            }
                        }
                        .padding()

                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else {
                            Button(action: viewModel.loadMorePhotos) {
                                Text("Load More")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                }
            }
            .onAppear(perform: viewModel.loadInitialPhotos)
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ContentView()
}

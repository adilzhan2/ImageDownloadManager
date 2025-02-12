//
//  ImageLoader.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import SwiftUI

struct ImageLoader: View {
    @StateObject private var viewModel = ImageLoaderViewModel()
    let imageUrl: String
    var text: String?
    private let size: CGFloat = (UIScreen.main.bounds.width - 32)


    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(viewModel.isPaused ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(width: size, height: size)
                .onTapGesture {
                    viewModel.togglePause()
                }

            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                ProgressCircleWithCancel(progress: viewModel.loadingProgress) {
                    viewModel.cancelLoading(url: imageUrl)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchImage(url: imageUrl)
            }
        }
        .onDisappear {
            viewModel.cancelLoading(url: imageUrl)
        }
    }
}

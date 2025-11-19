//
//  CheatResultScreenView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/18.
//

import SwiftUI

struct CheatResultScreenView: View {
    @EnvironmentObject private var headerViewModel: HeaderViewModel
    @EnvironmentObject private var navigationRouter: CheatScreenNavigationRouter
    @ObservedObject private var viewModel: CheatResultScreenViewModel
    private let imageViewPadding: CGFloat = 10
    private var imageViewAreaSize: CGSize {
        let imageViewAreaWidth = UIScreen.main.bounds.width - 2 * imageViewPadding
        let imageViewSideLength = (imageViewAreaWidth - imageViewPadding) / 2
        return .init(width: imageViewAreaWidth, height: imageViewSideLength)
    }
    private var separatedImageAreaSize: CGSize {
        let imageViewAreaWidth = UIScreen.main.bounds.width - 2 * imageViewPadding
        let imageViewSideLength = (imageViewAreaWidth - imageViewPadding) / 2
        return .init(width: imageViewSideLength, height: imageViewSideLength)
    }

    init(image: UIImage) {
        viewModel = .init(image: image)
    }

    var body: some View {
        VStack {
            switch viewModel.imageSuite {
            case .single(let image):
                Image(uiImage: image)
                    .resizable()
                    .frame(
                        maxWidth: imageViewAreaSize.width,
                        maxHeight: imageViewAreaSize.height
                    )
                    .padding(imageViewPadding)
            case .double(let leftImage, let rightImage):
                HStack(spacing: imageViewPadding) {
                    Image(uiImage: leftImage)
                        .resizable()
                        .frame(
                            maxWidth: separatedImageAreaSize.width,
                            maxHeight: separatedImageAreaSize.height
                        )
                    Image(uiImage: rightImage)
                        .resizable()
                        .frame(
                            maxWidth: separatedImageAreaSize.width,
                            maxHeight: separatedImageAreaSize.height
                        )
                }
                .padding(imageViewPadding)
            }
            if let resultImage = viewModel.resultImage {
                Image(uiImage: resultImage)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Rectangle()
                    .fill(.gray)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(imageViewPadding)
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await viewModel.detectDifferences() { str in
                headerViewModel.updateText(str)
            }
        }
    }
}

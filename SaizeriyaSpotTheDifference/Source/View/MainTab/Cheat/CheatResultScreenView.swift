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
    @State private var doubleImageSuiteSpacing: CGFloat = 0
    private let imageViewPadding: CGFloat = 10
    private var singleImageSuiteAreaSize: CGSize {
        let width = doubleImageSuiteAreaSize.width * 2
        let height = doubleImageSuiteAreaSize.height
        return .init(width: width, height: height)
    }
    private var doubleImageSuiteAreaSize: CGSize {
        let areaWidth = UIScreen.main.bounds.width - 2 * imageViewPadding
        let sideLength = (areaWidth - imageViewPadding) / 2
        return .init(width: sideLength, height: sideLength)
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
                        maxWidth: singleImageSuiteAreaSize.width,
                        maxHeight: singleImageSuiteAreaSize.height
                    )
                    .padding(.vertical, imageViewPadding)
            case .double(let leftImage, let rightImage):
                HStack(spacing: doubleImageSuiteSpacing) {
                    Image(uiImage: leftImage)
                        .resizable()
                        .frame(
                            maxWidth: doubleImageSuiteAreaSize.width,
                            maxHeight: doubleImageSuiteAreaSize.height
                        )
                    Image(uiImage: rightImage)
                        .resizable()
                        .frame(
                            maxWidth: doubleImageSuiteAreaSize.width,
                            maxHeight: doubleImageSuiteAreaSize.height
                        )
                }
                .padding(.vertical, imageViewPadding)
                .onAppear {
                    doubleImageSuiteSpacing = imageViewPadding
                }
                .animation(.easeInOut(duration: 0.3), value: doubleImageSuiteSpacing)
            }
            if let resultImage = viewModel.resultImage {
                Image(uiImage: resultImage)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(imageViewPadding)
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

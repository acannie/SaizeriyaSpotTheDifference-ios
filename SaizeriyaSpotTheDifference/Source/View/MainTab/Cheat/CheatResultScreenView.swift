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
    @State private var detectDifferencesTask: Task<Void, Never>?
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

    init(
        imageSuite: ImageSuite,
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat,
        imageSource: ImageSource
    ) {
        viewModel = .init(
            imageSuite: imageSuite,
            layoutHeight: layoutHeight,
            cameraPreviewFooterHeight: cameraPreviewFooterHeight,
            imageSource: imageSource
        )
    }

    var body: some View {
        VStack {
            switch viewModel.imageSuite {
            case .photosPickerItem:
                photosPickerItemImageSuite
            case .single(let image):
                singleImageSuite(image)
            case .double(let leftImage, let rightImage):
                doubleImageSuite(left: leftImage, right: rightImage)
            }
            result
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            detectDifferencesTask = Task {
                do {
                    try? await Task.sleep(for: .seconds(1))
                    try await viewModel.detectDifferences() { text, isLoading in
                        headerViewModel.updateText(text, isLoading: isLoading)
                    }
                } catch {
                    return
                }
            }
        }
        .onDisappear {
            detectDifferencesTask?.cancel()
        }
        .alert("エラー", isPresented: $viewModel.showsErrorAlert) {
            Button("再撮影") {
                navigationRouter.path.removeLast()
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private extension CheatResultScreenView {
    func singleImageSuite(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(
                maxWidth: singleImageSuiteAreaSize.width,
                maxHeight: singleImageSuiteAreaSize.height
            )
            .padding(.vertical, imageViewPadding)
    }

    func doubleImageSuite(left leftImage: UIImage, right rightImage: UIImage) -> some View {
        HStack(spacing: doubleImageSuiteSpacing) {
            Image(uiImage: leftImage)
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth: doubleImageSuiteAreaSize.width,
                    maxHeight: doubleImageSuiteAreaSize.height
                )
            Image(uiImage: rightImage)
                .resizable()
                .scaledToFit()
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

    var photosPickerItemImageSuite: some View {
        HStack(spacing: 4) {
            ForEach(0..<2, id: \.self) { _ in
                ZStack {
                    Rectangle()
                        .foregroundStyle(.gray)
                        .frame(
                            maxWidth: singleImageSuiteAreaSize.width / 2,
                            maxHeight: singleImageSuiteAreaSize.height
                        )
                        .padding(.vertical, imageViewPadding)
                    CrestView(color: .white, backgroundColor: .gray)
                }
            }
        }
    }

    @ViewBuilder
    var result: some View {
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
}

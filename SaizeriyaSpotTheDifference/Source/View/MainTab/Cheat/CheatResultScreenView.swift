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
    @State private var showingLayerSide: Side = .left
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
        imagePayload: ImagePayload,
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat,
        imageSource: ImageSource
    ) {
        viewModel = .init(
            imageSuite: .init(
                processing: imagePayload,
                preview: imagePayload,
                result: nil
            ),
            layoutHeight: layoutHeight,
            cameraPreviewFooterHeight: cameraPreviewFooterHeight,
            imageSource: imageSource
        )
    }

    var body: some View {
        VStack {
            switch viewModel.imageSuite.preview {
            case .photosPickerItem:
                photosPickerItemImageSuite
            case .single(let image):
                switch image {
                case .cg(let cgImage):
                    singleImageSuite(cgImage)
                case .ci(let ciImage):
                    if let cgImage = viewModel.convertToCgImage(from: ciImage) {
                        singleImageSuite(cgImage)
                    } else {
                        Text("表示に失敗しました")
                    }
                }
            case .pair(let imagePair):
                switch imagePair {
                case .cg(let leftCgImage, let rightCgImage):
                    doubleImageSuite(left: leftCgImage, right: rightCgImage)
                case .ci(let leftCiImage, let rightCiImage):
                    if let leftCgImage = viewModel.convertToCgImage(from: leftCiImage),
                       let rightCgImage = viewModel.convertToCgImage(from: rightCiImage) {
                        doubleImageSuite(left: leftCgImage, right: rightCgImage)
                    } else {
                        Text("表示に失敗しました")
                    }
                }
            case .differenceMask:
                EmptyView() // ここに辿り着くことはない
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
    func singleImageSuite(_ cgImage: CGImage) -> some View {
        Image(decorative: cgImage, scale: 1.0, orientation: .up)
            .resizable()
            .scaledToFit()
            .frame(
                maxWidth: singleImageSuiteAreaSize.width,
                maxHeight: singleImageSuiteAreaSize.height
            )
            .padding(.vertical, imageViewPadding)
    }

    func doubleImageSuite(left leftImage: CGImage, right rightImage: CGImage) -> some View {
        HStack(spacing: doubleImageSuiteSpacing) {
            Image(decorative: leftImage, scale: 1.0, orientation: .up)
                .resizable()
                .scaledToFit()
                .frame(
                    maxWidth: doubleImageSuiteAreaSize.width,
                    maxHeight: doubleImageSuiteAreaSize.height
                )
            Image(decorative: rightImage, scale: 1.0, orientation: .up)
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
            ZStack {
                Image(decorative: resultImage.baseImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(imageViewPadding)
                Rectangle()
                    .foregroundStyle(.resultImageFilter)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(imageViewPadding)
                ForEach(resultImage.leftImageDifferenceLayers, id: \.self) { layer in
                    Image(decorative: layer, scale: 1.0, orientation: .up)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(imageViewPadding)
                        .opacity(showingLayerSide.isLeft ? 1 : 0)
                }
                ForEach(resultImage.rightImageDifferenceLayers, id: \.self) { layer in
                    Image(decorative: layer, scale: 1.0, orientation: .up)
                        .resizable()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(imageViewPadding)
                        .opacity(showingLayerSide.isLeft ? 0 : 1)
                }
            }
            .animation(
                .easeInOut(duration: 0.5).delay(0.5).repeatForever(autoreverses: true),
                value: showingLayerSide
            )
            .onAppear {
                showingLayerSide = .right
            }
        } else {
            Rectangle()
                .fill(.gray)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(imageViewPadding)
        }
    }
}

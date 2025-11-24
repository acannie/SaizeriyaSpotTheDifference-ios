//
//  CheatResultScreenViewModel.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/19.
//

import SwiftUI
import Combine

final class CheatResultScreenViewModel: ObservableObject {
    @Published private(set) var imageSuite: ImageSuite
    @Published private(set) var resultImage: UIImage?
    private let createImageTasks: [CreateImageTaskExecutable]
    @Published var showsErrorAlert: Bool = false
    @Published private(set) var errorMessage: String?

    init(image: UIImage, layoutHeight: LayoutHeight, cameraPreviewFooterHeight: CGFloat) {
        self.imageSuite = .single(image)
        self.createImageTasks = [
            ClipImageTask(layoutHeight: layoutHeight, cameraPreviewFooterHeight: cameraPreviewFooterHeight),
            DetectRectangleAndPerspectiveCorrectTask(),
            PosterizeTask(),
            SplitAndResizeTask(),
    //        TakeEffectsTask(),
    //        ColorClusteringTask(),
    //        CoordinateClusteringTask(),
    //        DifferingPixelCoordinatesTask()
        ]
    }

    func detectDifferences(updateHeaderText: @escaping (String) -> Void) async {
        for task in createImageTasks {
            updateHeaderText(task.headerText)
            do {
                let imageSuite = try await Task.detached {
                    try await task.createImageSuite(from: self.imageSuite)
                }.value
                self.imageSuite = imageSuite
            } catch let error as CreateImageTaskError {
                showAlert(message: error.description)
                return
            } catch {
                showAlert(message: "予期せぬエラーが発生しました")
                return
            }
        }
        switch imageSuite {
        case .single:
            updateHeaderText("処理を最後まで完了できませんでした")
        case .double(let left, let right):
            updateHeaderText("間違い探しが完了しました！")
            resultImage = left
        }
    }
}

private extension CheatResultScreenViewModel {
    func showAlert(message: String) {
        self.errorMessage = message
        self.showsErrorAlert = true
    }
}

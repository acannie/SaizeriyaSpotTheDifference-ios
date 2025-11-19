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
    private let createImageTasks: [CreateImageTaskExecutable] = [
        DetectRectangleAndPerspectiveCorrectTask(),
        SplitAndResizeTask(),
        TakeEffectsTask(),
        ColorClusteringTask(),
        CoordinateClusteringTask(),
        DifferingPixelCoordinatesTask()
    ]
    @Published var showsErrorAlert: Bool = false
    @Published private(set) var errorMessage: String?

    init(image: UIImage) {
        self.imageSuite = .single(image)
    }

    func detectDifferences(updateHeaderText: @escaping (String) -> Void) async {
        for task in createImageTasks {
            updateHeaderText(task.headerText)
            do {
                let imageSuite = try await task.createImageSuite(from: imageSuite)
                self.imageSuite = imageSuite
            } catch {
                showAlert(message: error.localizedDescription)
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

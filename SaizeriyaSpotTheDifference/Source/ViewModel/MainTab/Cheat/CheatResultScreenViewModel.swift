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
    @Published private(set) var resultImage: ResultImagePayload?
    @Published var showsErrorAlert: Bool = false
    @Published private(set) var errorMessage: String?
    private let layoutHeight: LayoutHeight
    private let cameraPreviewFooterHeight: CGFloat
    private let imageSource: ImageSource

    init(
        imageSuite: ImageSuite,
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat,
        imageSource: ImageSource
    ) {
        self.imageSuite = imageSuite
        self.layoutHeight = layoutHeight
        self.cameraPreviewFooterHeight = cameraPreviewFooterHeight
        self.imageSource = imageSource
    }

    func detectDifferences(updateHeaderText: @escaping (String, Bool) -> Void) async throws {
        for task in CreateImageTask.allCases {
            try Task.checkCancellation()

            if !task.isNeedToExecute(imageSource: imageSource) {
                continue
            }
            let executable = task.executable(
                layoutHeight: layoutHeight,
                cameraPreviewFooterHeight: cameraPreviewFooterHeight
            )
            updateHeaderText(executable.headerText, true)
            do {
                self.imageSuite = try await Task.detached {
                    try await executable.process(from: self.imageSuite)
                }.value
            } catch let error as CreateImageTaskError {
                updateHeaderText("処理を最後まで完了できませんでした", false)
                showAlert(message: error.description)
                return
            } catch {
                updateHeaderText("処理を最後まで完了できませんでした", false)
                showAlert(message: "予期せぬエラーが発生しました")
                return
            }
        }
        // FIXME: 最後のタスクが完成するまでの暫定処理
        if let resultImage = imageSuite.result {
            updateHeaderText("間違い探しが完了しました！", false)
            self.resultImage = resultImage
        }
    }
}

private extension CheatResultScreenViewModel {
    func showAlert(message: String) {
        self.errorMessage = message
        self.showsErrorAlert = true
    }
}

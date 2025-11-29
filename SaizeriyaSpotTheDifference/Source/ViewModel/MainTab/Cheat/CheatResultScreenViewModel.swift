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
    @Published var showsErrorAlert: Bool = false
    @Published private(set) var errorMessage: String?
    private let layoutHeight: LayoutHeight
    private let cameraPreviewFooterHeight: CGFloat
    private let isCapturedImage: Bool

    init(
        image: UIImage,
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat,
        isCapturedImage: Bool
    ) {
        self.imageSuite = .single(image)
        self.layoutHeight = layoutHeight
        self.cameraPreviewFooterHeight = cameraPreviewFooterHeight
        self.isCapturedImage = isCapturedImage
    }

    func detectDifferences(updateHeaderText: @escaping (String, Bool) -> Void) async {
        for task in CreateImageTask.allCases {
            if !task.isNeedToExecute(isCapturedImage: isCapturedImage) {
                continue
            }
            let executable = task.executable(
                layoutHeight: layoutHeight,
                cameraPreviewFooterHeight: cameraPreviewFooterHeight
            )
            updateHeaderText(executable.headerText, true)
            do {
                let imageSuite = try await Task.detached {
                    try await executable.createImageSuite(from: self.imageSuite)
                }.value
                self.imageSuite = imageSuite
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
        switch imageSuite {
        case .single:
            break
        case .double(let left, let right):
            updateHeaderText("間違い探しが完了しました！", false)
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

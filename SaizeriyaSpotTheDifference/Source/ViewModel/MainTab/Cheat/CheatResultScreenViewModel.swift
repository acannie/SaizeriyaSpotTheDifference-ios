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
        DetectRectangleAndPerspectiveCorrectTask()
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
                let imageSuite = try await task.createImage(from: imageSuite)
                self.imageSuite = imageSuite
            } catch {
                showAlert(message: error.localizedDescription)
            }
        }
        switch imageSuite {
        case .single:
            print("処理を最後まで完了できませんでした")
        case .double(let left, let right):
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

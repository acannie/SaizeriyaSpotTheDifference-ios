//
//  CheatResultScreenViewModel.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/19.
//

import SwiftUI
import Combine

final class CheatResultScreenViewModel: ObservableObject {
    enum ImageType {
        case single(UIImage)
        case double(left: UIImage, right: UIImage)
    }
    @Published private(set) var imageType: ImageType
    @Published private(set) var resultImage: UIImage?

    init(image: UIImage) {
        self.imageType = .single(image)
    }

    func detectDifferences(updateHeaderText: @escaping (String) -> Void) async {
        updateHeaderText("間違い探しを認識中……")
        try? await Task.sleep(for: .seconds(1))
        updateHeaderText("イラストを認識中……")
        try? await Task.sleep(for: .seconds(1))
        updateHeaderText("間違いを検出中……")
        try? await Task.sleep(for: .seconds(1))
        updateHeaderText("間違い検出完了！")
    }
}

private extension CheatResultScreenView {
    
}

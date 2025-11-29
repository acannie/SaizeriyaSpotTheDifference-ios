//
//  CheatScreenNavigationRouter.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI
import Combine

class CheatScreenNavigationRouter: ObservableObject {
    @Published var path = [Key]()

    enum Key: Hashable {
        case shooting
        case result(ImageSuite, from: ImageSource, cameraPreviewFooterHeight: CGFloat)

        @ViewBuilder
        func destination(layoutHeight: LayoutHeight) -> some View {
            switch self {
            case .shooting:
                ShootingScreenView()
            case .result(let imageSuite, let imageSource, let cameraPreviewFooterHeight):
                CheatResultScreenView(
                    imageSuite: imageSuite,
                    layoutHeight: layoutHeight,
                    cameraPreviewFooterHeight: cameraPreviewFooterHeight,
                    imageSource: imageSource
                )
            }
        }
    }
}

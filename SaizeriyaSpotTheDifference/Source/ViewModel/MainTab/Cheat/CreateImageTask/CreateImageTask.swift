//
//  CreateImageTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/29.
//

import Foundation

enum CreateImageTask: CaseIterable {
    case clipImage
    case detectRectangleAndPerspectiveCorrect
    case posterize
    case splitAndResize
//    case takeEffects
//    case colorClustering
//    case differingPixelCoordinates

    func executable(
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat
    ) -> CreateImageTaskExecutable {
        switch self {
        case .clipImage:
            ClipImageTask(layoutHeight: layoutHeight, cameraPreviewFooterHeight: cameraPreviewFooterHeight)
        case .detectRectangleAndPerspectiveCorrect:
            DetectRectangleAndPerspectiveCorrectTask()
        case .posterize:
            PosterizeTask()
        case .splitAndResize:
            SplitAndResizeTask()
//        case .takeEffects:
//            TakeEffectsTask()
//        case .colorClustering:
//            ColorClusteringTask()
//        case .differingPixelCoordinates:
//            DifferingPixelCoordinatesTask()
        }
    }
}

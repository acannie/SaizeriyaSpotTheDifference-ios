//
//  CreateImageTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/29.
//

import Foundation

enum CreateImageTask: CaseIterable {
    case loadTransferable
    case clipImage
    case detectRectangleAndPerspectiveCorrect
    case reduction
    case posterize
    case splitAndResize
    case adjustOffset
    case differenceExtraction

    func executable(
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat
    ) -> CreateImageTaskExecutable {
        switch self {
        case .loadTransferable:
            LoadTransferableTask()
        case .clipImage:
            ClipImageTask(
                layoutHeight: layoutHeight,
                cameraPreviewFooterHeight: cameraPreviewFooterHeight
            )
        case .detectRectangleAndPerspectiveCorrect:
            DetectRectangleAndPerspectiveCorrectTask()
        case .reduction:
            ReductionTask()
        case .posterize:
            PosterizeTask()
        case .splitAndResize:
            SplitAndResizeTask()
        case .adjustOffset:
            AdjustOffsetTask()
        case .differenceExtraction:
            DifferenceExtractionTask()
        }
    }

    func isNeedToExecute(imageSource: ImageSource) -> Bool {
        switch self {
        case .loadTransferable:
            imageSource == .photoPicker
        case .clipImage:
            imageSource == .camera
        default:
            true
        }
    }
}

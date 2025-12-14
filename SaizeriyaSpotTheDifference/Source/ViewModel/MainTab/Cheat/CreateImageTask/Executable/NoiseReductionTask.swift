//
//  NoiseReductionTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/15.
//

import UIKit

struct NoiseReductionTask: CreateImageTaskExecutable {
    let headerText: String = "ノイズ除去中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .differenceMask(var mask) = imageSuite.processing else {
            throw CreateImageTaskError.unexpectedError
        }

        // 領域に分割
        let masks: Set<Set<PixelCoordinate>>

        return .init(
            processing: .differenceMask(mask),
            preview: imageSuite.preview,
            result: nil
        )
    }
}

private extension NoiseReductionTask {
    
}

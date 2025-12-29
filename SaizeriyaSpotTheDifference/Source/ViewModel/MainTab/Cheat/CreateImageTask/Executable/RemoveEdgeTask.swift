//
//  RemoveEdgeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/29.
//

import UIKit

struct RemoveEdgeTask: CreateImageTaskExecutable {
    let headerText: String = "ノイズ除去中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard
            case .differenceMask(var mask) = imageSuite.processing,
            case .pair(let imagePair) = imageSuite.preview
        else {
            throw CreateImageTaskError.unexpectedError
        }

        // 画像のサイズを取得
        let (previewLeftCgImage, previewRightCgImage) = try getCgImagePair(from: imagePair)
        let imageSize = CGSize(width: previewLeftCgImage.width, height: previewLeftCgImage.height)


        // ResultPayloadを作成
        let differencesOnLeftImage = try await previewLeftCgImage.extractPixels(at: mask.coordinates)
        let differencesOnRightImage = try await previewRightCgImage.extractPixels(at: mask.coordinates)

        return .init(
            processing: .differenceMask(mask),
            preview: imageSuite.preview,
            result: .init(
                baseImage: previewLeftCgImage,
                leftImageDifferenceLayers: [differencesOnLeftImage],
                rightImageDifferenceLayers: [differencesOnRightImage]
            )
        )
    }
}


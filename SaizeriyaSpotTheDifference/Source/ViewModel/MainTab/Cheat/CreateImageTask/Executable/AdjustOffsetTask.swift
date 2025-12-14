//
//  AdjustOffsetTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/02.
//

import UIKit

struct AdjustOffsetTask: CreateImageTaskExecutable {
    let headerText: String = "位置を調整中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .pair(let imagePair) = imageSuite.processing,
              case .pair(let previewImagePair) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }
        let (leftCgImage, rightCgImage) = try getCgImagePair(from: imagePair)
        let (previewLeftCgImage, previewRightCgImage) = try getCgImagePair(from: previewImagePair)

        // 最適なオフセットを探索
        let optimalOffset = try await findOptimalOffset(leftCgImage, rightCgImage)

        // オフセット分ずらした画像を作成
        let imageWidth = leftCgImage.width
        let imageHeight = leftCgImage.height
        let newImageSize = CGSize(
            width: imageWidth - abs(optimalOffset.x),
            height: imageHeight - abs(optimalOffset.y),
        )
        let leftImageCropRect = CGRect(
            x: optimalOffset.x > 0 ? CGFloat(optimalOffset.x) : 0,
            y: optimalOffset.y > 0 ? CGFloat(optimalOffset.y) : 0,
            width: newImageSize.width,
            height: newImageSize.height
        )
        let rightImageCropRect = CGRect(
            x: optimalOffset.x > 0 ? 0 : -CGFloat(optimalOffset.x),
            y: optimalOffset.y > 0 ? 0 : -CGFloat(optimalOffset.y),
            width: newImageSize.width,
            height: newImageSize.height
        )
        guard let optimizedProcessingLeft = leftCgImage.cropping(to: leftImageCropRect),
              let optimizedProcessingRight = rightCgImage.cropping(to: rightImageCropRect),
              let optimizedPreviewLeft = previewLeftCgImage.cropping(to: leftImageCropRect),
              let optimizedPreviewRight = previewRightCgImage.cropping(to: rightImageCropRect) else {
            throw CreateImageTaskError.unexpectedError
        }

        return .init(
            processing: .pair(.cg(optimizedProcessingLeft, optimizedProcessingRight)),
            preview: .pair(.cg(optimizedPreviewLeft, optimizedPreviewRight)),
            result: nil
        )
    }
}

private extension AdjustOffsetTask {
    func findOptimalOffset(
        _ leftImage: CGImage,
        _ rightImage: CGImage,
        sampleCount: Int = 1000,
        offsetRange: ClosedRange<Int> = -30...30
    ) async throws -> ImageCoordinate {
        guard
            leftImage.width == rightImage.width,
            leftImage.height == rightImage.height else {
            throw CreateImageTaskError.unexpectedError
        }
        let imageWidth = Int(leftImage.width)
        let imageHeight = Int(leftImage.height)
        let leftRgbGrid = try await RgbGrid(leftImage)
        let rightRgbGrid = try await RgbGrid(rightImage)

        let randomImageCoordinates: [ImageCoordinate] = (0..<sampleCount).map { _ in
            .init(
                x: Int.random(in: 0..<imageWidth),
                y: Int.random(in: 0..<imageHeight)
            )
        }

        // 差分が最小となるオフセットを探索する
        var minDiffCount: Int = sampleCount
        var optimalOffset: ImageCoordinate = .init(x: 0, y: 0)
        for y in offsetRange {
            for x in offsetRange {
                let offset = ImageCoordinate(x: x, y: y)
                var diffCount = 0

                for coordinate in randomImageCoordinates {
                    let leftImageCoordinate = coordinate.add(offset)
                    let rightImageCoordinates = coordinate

                    if 0 < leftImageCoordinate.x, leftImageCoordinate.x < imageWidth,
                       0 < leftImageCoordinate.y, leftImageCoordinate.y < imageHeight {
                        let leftRgb = leftRgbGrid.pixel(leftImageCoordinate)
                        let rightRgb = rightRgbGrid.pixel(rightImageCoordinates)
                        if leftRgb.labDistance(from: rightRgb) > 0.2 { // 後続タスクの基準と合わせる
                            diffCount += 1
                        }
                    }
                }

                if diffCount < minDiffCount {
                    minDiffCount = diffCount
                    optimalOffset = offset
                }
            }
        }
        return optimalOffset
    }
}

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
        guard case .double(let left, let right) = imageSuite.processing,
              case .double(let previewLeft, let previewRight) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }

        // 最適なオフセットを探索
        let optimalOffset = try await findOptimalOffset(left, right)

        // オフセット分ずらした画像を作成
        let imageSize = left.size
        let newImageSize = CGSize(
            width: imageSize.width - CGFloat(abs(optimalOffset.x)),
            height: imageSize.height - CGFloat(abs(optimalOffset.y)),
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
        guard let optimizedProcessingLeft = left.cropping(to: leftImageCropRect),
              let optimizedProcessingRight = right.cropping(to: rightImageCropRect),
              let optimizedPreviewLeft = previewLeft.cropping(to: leftImageCropRect),
              let optimizedPreviewRight = previewRight.cropping(to: rightImageCropRect) else {
            throw CreateImageTaskError.unexpectedError
        }

        return .init(
            processing: .double(left: optimizedProcessingLeft, right: optimizedProcessingRight),
            preview: .double(left: optimizedPreviewLeft, right: optimizedPreviewRight),
            result: nil
        )
    }
}

private extension AdjustOffsetTask {
    func findOptimalOffset(
        _ leftImage: UIImage,
        _ rightImage: UIImage,
        sampleCount: Int = 100,
        offsetRange: ClosedRange<Int> = -30...30
    ) async throws -> ImageCoordinate {
        guard leftImage.size == rightImage.size else {
            throw CreateImageTaskError.unexpectedError
        }
        let imageWidth = Int(leftImage.size.width)
        let imageHeight = Int(leftImage.size.height)
        let leftRgbGrid = try await RgbGrid(leftImage)
        let rightRgbGrid = try await RgbGrid(rightImage)

        let randomImageCoordinates: [ImageCoordinate] = (0..<sampleCount).map { _ in
            .init(
                x: Int.random(in: 0..<imageWidth),
                y: Int.random(in: 0..<imageHeight)
            )
        }

        // 差分が最小となるオフセットを探索する
        var minDiffAverage: CGFloat = .infinity
        var optimalOffset: ImageCoordinate = .init(x: 0, y: 0)
        for y in offsetRange {
            for x in offsetRange {
                let offset = ImageCoordinate(x: x, y: y)
                var diffSum: CGFloat = 0
                var targetCount: Int = 0

                for coordinate in randomImageCoordinates {
                    let leftImageCoordinate = coordinate.add(offset)
                    let rightImageCoordinates = coordinate

                    if 0 < leftImageCoordinate.x, leftImageCoordinate.x < imageWidth,
                       0 < leftImageCoordinate.y, leftImageCoordinate.y < imageHeight {
                        let leftRgb = leftRgbGrid.pixel(leftImageCoordinate)
                        let rightRgb = rightRgbGrid.pixel(rightImageCoordinates)
                        diffSum += leftRgb.distance(from: rightRgb)
                        targetCount += 1
                    } else {
                        break
                    }
                }

                let diffAverage = diffSum / Double(targetCount)
                if diffAverage < minDiffAverage {
                    minDiffAverage = diffAverage
                    optimalOffset = offset
                }
            }
        }
        return optimalOffset
    }
}

private extension ClipImageTask {
    func getPreviewedImage(from image: UIImage, scale: CGFloat) -> UIImage? {
        // x座標は0
        let originX: CGFloat = 0

        // y座標を計算
        let headerHeight = layoutHeight.headerHeight
        let contentHeight = layoutHeight.contentHeight
        let cameraPreviewHeight = contentHeight - cameraPreviewFooterHeight
        let originY = headerHeight

        // トリミング開始地点
        let cropRect = CGRect(
            x: originX * scale,
            y: originY * scale,
            width: UIScreen.main.bounds.width * scale,
            height: cameraPreviewHeight * scale
        )

        return image.cropping(to: cropRect)
    }
}

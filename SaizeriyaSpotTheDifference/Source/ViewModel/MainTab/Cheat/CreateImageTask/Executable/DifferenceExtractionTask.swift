//
//  DifferingPixelCoordinatesTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit

// 精度を確認するための仮実装
struct DifferenceExtractionTask: CreateImageTaskExecutable {
    let headerText: String = "差分を検出中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .pair(let imagePair) = imageSuite.processing,
              case .pair(let previewImagePair) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }
        let (leftCgImage, rightCgImage) = try getCgImagePair(from: imagePair)
        let (previewLeftCgImage, previewRightCgImage) = try getCgImagePair(from: previewImagePair)

        // 差分を抽出
        let differenceCoordinates: Set<PixelCoordinate> = try await getDifferenceCoordinates(leftCgImage, rightCgImage)
        let differencesOnLeftImage = try await previewLeftCgImage.extractPixels(at: differenceCoordinates)
        let differencesOnRightImage = try await previewRightCgImage.extractPixels(at: differenceCoordinates)

        // ResultPayloadを作成
        let mask = ImageMask(coordinates: differenceCoordinates)
        let baseImage = previewLeftCgImage

        return .init(
            processing: .differenceMask(mask),
            preview: imageSuite.preview,
            result: .init(
                baseImage: baseImage,
                leftImageDifferenceLayers: [differencesOnLeftImage],
                rightImageDifferenceLayers: [differencesOnRightImage]
            )
        )
    }
}

private extension DifferenceExtractionTask {
    func getDifferenceCoordinates(
        _ leftImage: CGImage,
        _ rightImage: CGImage
    ) async throws -> Set<PixelCoordinate> {
        guard
            leftImage.width == rightImage.width,
            leftImage.height == rightImage.height else {
            throw CreateImageTaskError.unexpectedError
        }
        let leftRgbGrid = try await RgbGrid(leftImage)
        let rightRgbGrid = try await RgbGrid(rightImage)

        var differentCoordinates: Set<PixelCoordinate> = []
        for y in 0..<Int(leftImage.height) {
            for x in 0..<Int(leftImage.width) {
                let coorinate = PixelCoordinate(x: x, y: y)
                if isDifferent(
                    leftRgbGrid: leftRgbGrid,
                    rightRgbGrid: rightRgbGrid,
                    coordinate: coorinate
                ) {
                    differentCoordinates.insert(.init(x: x, y: y))
                }
            }
        }
        return differentCoordinates
    }

    func isDifferent(
        leftRgbGrid: RgbGrid,
        rightRgbGrid: RgbGrid,
        coordinate: PixelCoordinate
    ) -> Bool {
        // 8近傍で最もLabΔE距離が小さいものが閾値以上であるか判定する
        var minLabDeltaE: Double = .infinity
        let baseColor = leftRgbGrid.pixel(coordinate)
        let imageWidth = leftRgbGrid.width
        let imageHeight = leftRgbGrid.height

        let offset = 1
        for offsetX in -offset...offset {
            for offsetY in -offset...offset {
                if abs(offsetX) + abs(offsetY) != 1 {
                    continue
                }
                let targetCoordinateX = coordinate.x + offsetX
                let targetCoordinateY = coordinate.y + offsetY
                guard
                    0 <= targetCoordinateX, targetCoordinateX < imageWidth,
                    0 <= targetCoordinateY, targetCoordinateY < imageHeight else {
                    continue
                }

                let targetCoordinate = PixelCoordinate(
                    x: targetCoordinateX,
                    y: targetCoordinateY
                )
                let targetPixelColor = rightRgbGrid.pixel(targetCoordinate)
                let labDeltaE = baseColor.labDistance(from: targetPixelColor)
                if labDeltaE < minLabDeltaE {
                    minLabDeltaE = labDeltaE
                }
            }
        }
        return minLabDeltaE > 0.01 // FIXME: 閾値調整
    }
}

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
                let leftImagePixelColor = leftRgbGrid.pixel(x, y)
                let rightImagePixelColor = rightRgbGrid.pixel(x, y)

                if leftImagePixelColor.labDistance(from: rightImagePixelColor) > 0.2 { // FIXME: 閾値調整
                    differentCoordinates.insert(.init(x: x, y: y))
                }
            }
        }
        return differentCoordinates
    }
}

private extension CGImage {
    func extractPixels(at coordinates: Set<PixelCoordinate>) async throws -> CGImage {
        let baseImageRgbGrid = try await RgbGrid(self)

        var rgbRows: [[Rgb]] = []
        for y in 0..<self.height {
            var row: [Rgb] = []
            for x in 0..<self.width {
                let coordinate = PixelCoordinate(x: x, y: y)
                if coordinates.contains(coordinate) {
                    row.append(baseImageRgbGrid.pixel(x, y))
                } else {
                    row.append(.init(r: 0, g: 0, b: 0))
                }
            }
            rgbRows.append(row)
        }
        let rgbGrid = try RgbGrid(rgbRows)
        return try rgbGrid.makeCGImage()
    }
}

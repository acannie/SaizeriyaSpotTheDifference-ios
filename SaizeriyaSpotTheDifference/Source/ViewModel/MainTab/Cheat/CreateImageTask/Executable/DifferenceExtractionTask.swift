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
        guard case .double(let left, let right) = imageSuite.processing,
              case .double(let previewLeft, let previewRight) = imageSuite.preview,
              let cgImageLeft = left.cgImage,
              let cgImageRight = right.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 差分を抽出
        let differenceCoordinates: Set<ImageCoordinate> = try await getDifferenceCoordinates(left, right)
        let differencesOnLeftImage = try await previewLeft.extractPixels(at: differenceCoordinates)
        let differencesOnRightImage = try await previewRight.extractPixels(at: differenceCoordinates)

        // ResultPayloadを作成
        guard case .double(let leftPreviewImage, _) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }
        let baseImage = leftPreviewImage

        return .init(
            processing: .differences(differenceCoordinates),
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
        _ leftImage: UIImage,
        _ rightImage: UIImage
    ) async throws -> Set<ImageCoordinate> {
        guard leftImage.size == rightImage.size else {
            throw CreateImageTaskError.unexpectedError
        }
        let leftRgbGrid = try await RgbGrid(leftImage)
        let rightRgbGrid = try await RgbGrid(rightImage)

        var differentCoordinates: Set<ImageCoordinate> = []
        for y in 0..<Int(leftImage.size.height) {
            for x in 0..<Int(leftImage.size.width) {
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

private extension UIImage {
    func extractPixels(at coordinates: Set<ImageCoordinate>) async throws -> UIImage {
        guard let cgImage = self.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }
        let baseImageRgbGrid = try await RgbGrid(self)

        var rgbRows: [[Rgb]] = []
        for y in 0..<cgImage.height {
            var row: [Rgb] = []
            for x in 0..<cgImage.width {
                let coordinate = ImageCoordinate(x: x, y: y)
                if coordinates.contains(coordinate) {
                    row.append(baseImageRgbGrid.pixel(x, y))
                } else {
                    row.append(.init(r: 0, g: 0, b: 0))
                }
            }
            rgbRows.append(row)
        }
        let rgbGrid = try RgbGrid(rgbRows)
        guard let image = try await rgbGrid.image() else {
            throw CreateImageTaskError.unexpectedError
        }
        return image
    }
}

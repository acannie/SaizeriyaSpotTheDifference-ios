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
        guard
            case .differenceMask(var mask) = imageSuite.processing,
            case .pair(let imagePair) = imageSuite.preview
        else {
            throw CreateImageTaskError.unexpectedError
        }

        // 画像のサイズを取得
        let (previewLeftCgImage, previewRightCgImage) = try getCgImagePair(from: imagePair)
        let imageSize = CGSize(width: previewLeftCgImage.width, height: previewLeftCgImage.height)

        // 領域に分割
        var masks = await mask.splitMaskIntoRegions(imageSize: imageSize)
        masks = reduceSmallRegion(from: masks)
        mask = ImageMask(regions: masks)

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

private extension ImageMask {
    func splitMaskIntoRegions(imageSize: CGSize) async -> Set<PixelRegion> {
        var alreadyChecked = Set<PixelCoordinate>()
        var regions = Set<PixelRegion>()

        // BFSで領域分割
        for coordinate in self.coordinates {
            if alreadyChecked.contains(coordinate) {
                continue
            }
            var region = PixelRegion()
            var willCheck = Set<PixelCoordinate>()
            willCheck.insert(coordinate)
            while let targetCoordinate = willCheck.popFirst() {
                if !self.contains(coordinate: targetCoordinate) {
                    continue
                }
                if alreadyChecked.contains(targetCoordinate) {
                    continue
                }
                region.insert(targetCoordinate)
                alreadyChecked.insert(targetCoordinate)

                // 隣接したピクセルをwillCheckに追加
//                let neibors = targetCoordinate.eightNeighbors(in: imageSize)
                let neibors = targetCoordinate.fourNeighbors(in: imageSize)
                for neibor in neibors {
                    willCheck.insert(neibor)
                }
            }
            regions.insert(region)
        }

        return regions
    }
}

private extension PixelCoordinate {
    func eightNeighbors(in size: CGSize) -> Set<PixelCoordinate> {
        let maxX = self.x + 1
        let minX = self.x - 1
        let maxY = self.y + 1
        let minY = self.y - 1
        let topOk = minY >= 0
        let leftOk = minX >= 0
        let rightOk = maxX < Int(size.width)
        let bottomOk = maxY < Int(size.height)

        var neighbors = Set<PixelCoordinate>()
        // 左上
        if topOk, leftOk {
            neighbors.insert(.init(x: minX, y: minY))
        }
        // 上
        if topOk {
            neighbors.insert(.init(x: self.x, y: minY))
        }
        // 右上
        if topOk, rightOk {
            neighbors.insert(.init(x: maxX, y: minY))
        }
        // 左
        if leftOk {
            neighbors.insert(.init(x: minX, y: self.y))
        }
        // 右
        if rightOk {
            neighbors.insert(.init(x: maxX, y: self.y))
        }
        // 左下
        if bottomOk, leftOk {
            neighbors.insert(.init(x: minX, y: maxY))
        }
        // 下
        if bottomOk {
            neighbors.insert(.init(x: self.x, y: maxY))
        }
        // 右下
        if bottomOk, rightOk {
            neighbors.insert(.init(x: maxX, y: maxY))
        }

        return neighbors
    }

    func fourNeighbors(in size: CGSize) -> Set<PixelCoordinate> {
        let maxX = self.x + 1
        let minX = self.x - 1
        let maxY = self.y + 1
        let minY = self.y - 1
        let topOk = minY >= 0
        let leftOk = minX >= 0
        let rightOk = maxX < Int(size.width)
        let bottomOk = maxY < Int(size.height)

        var neighbors = Set<PixelCoordinate>()
        // 上
        if topOk {
            neighbors.insert(.init(x: self.x, y: minY))
        }
        // 左
        if leftOk {
            neighbors.insert(.init(x: minX, y: self.y))
        }
        // 右
        if rightOk {
            neighbors.insert(.init(x: maxX, y: self.y))
        }
        // 下
        if bottomOk {
            neighbors.insert(.init(x: self.x, y: maxY))
        }
        return neighbors
    }
}

private extension NoiseReductionTask {
    func reduceSmallRegion(from regions: Set<PixelRegion>) -> Set<PixelRegion> {
        let largeRegions = regions.filter { $0.size > 10 }
        let top10Regions = largeRegions.sorted { $0.size > $1.size }.prefix(10)
        return Set<PixelRegion>(top10Regions)
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
                    row.append(.init(r: 0, g: 0, b: 0, a: 0))
                }
            }
            rgbRows.append(row)
        }
        let rgbGrid = try RgbGrid(rgbRows)
        return try rgbGrid.makeCGImage()
    }
}

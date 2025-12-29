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

        // 差分マスクを領域に分割
        var masks = await mask.splitMaskIntoRegions(imageSize: imageSize)
        masks = reduceSmallRegion(from: masks)
        mask = ImageMask(regions: masks)

        // 差分マスク外を領域に分割
        var nonMasks = await mask.getNonMaskRegions(imageSize: imageSize)
        nonMasks = reduceSmallRegion(from: nonMasks, isMask: false)

        // 差分マスク外領域を反転して差分マスクを得る
        var nonMaskCoordinates: Set<PixelCoordinate> = []
        for nonMask in nonMasks {
            nonMaskCoordinates.formUnion(nonMask.coordinates)
        }
        let maskCoordinates = reverseNonMaskToGetMask(nonMaskCoordinates, in: imageSize)
        mask = ImageMask(coordinates: maskCoordinates)

        // 再度差分マスクを領域に分割
        masks = await mask.splitMaskIntoRegions(imageSize: imageSize)

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
                let neibors = targetCoordinate.neighbors(.four, in: imageSize)
                for neibor in neibors {
                    willCheck.insert(neibor)
                }
            }
            regions.insert(region)
        }

        return regions
    }

    func getNonMaskRegions(imageSize: CGSize) async -> Set<PixelRegion> {
        var alreadyChecked = Set<PixelCoordinate>()
        var regions = Set<PixelRegion>()

        // BFSで領域分割
        for y in 0..<Int(imageSize.height) {
            for x in 0..<Int(imageSize.width) {
                let coordinate = PixelCoordinate(x: x, y: y)
                if coordinates.contains(coordinate) {
                    continue
                }
                if alreadyChecked.contains(coordinate) {
                    continue
                }
                var region = PixelRegion()
                var willCheck = Set<PixelCoordinate>()
                willCheck.insert(coordinate)
                while let targetCoordinate = willCheck.popFirst() {
                    if self.contains(coordinate: targetCoordinate) {
                        continue
                    }
                    if alreadyChecked.contains(targetCoordinate) {
                        continue
                    }
                    region.insert(targetCoordinate)
                    alreadyChecked.insert(targetCoordinate)

                    // 隣接したピクセルをwillCheckに追加
                    let neibors = targetCoordinate.neighbors(.four, in: imageSize)
                    for neibor in neibors {
                        willCheck.insert(neibor)
                    }
                }
                regions.insert(region)
            }
        }

        return regions
    }
}

private extension PixelCoordinate {
    enum NeiborType {
        case four
        case eight
    }

    func neighbors(_ type: NeiborType, in size: CGSize) -> Set<PixelCoordinate> {
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
        if type == .eight {
            // 左上
            if topOk, leftOk {
                neighbors.insert(.init(x: minX, y: minY))
            }
            // 右上
            if topOk, rightOk {
                neighbors.insert(.init(x: maxX, y: minY))
            }
            // 左下
            if bottomOk, leftOk {
                neighbors.insert(.init(x: minX, y: maxY))
            }
            // 右下
            if bottomOk, rightOk {
                neighbors.insert(.init(x: maxX, y: maxY))
            }
        }

        return neighbors
    }
}

private extension NoiseReductionTask {
    func reduceSmallRegion(from regions: Set<PixelRegion>, isMask: Bool = true) -> Set<PixelRegion> {
        let threthold = isMask ? 10 : 100
        let largeRegions = regions.filter { $0.size > threthold }
        let regionCount = isMask ? 100 : 1
        let top10Regions = largeRegions.sorted { $0.size > $1.size }.prefix(regionCount)
        return Set<PixelRegion>(top10Regions)
    }

    func reverseNonMaskToGetMask(_ nonMaskRegion: Set<PixelCoordinate>, in size: CGSize) -> Set<PixelCoordinate> {
        var allPixels = Set<PixelCoordinate>()
        for y in 0..<Int(size.height) {
            for x in 0..<Int(size.width) {
                let cooridinate = PixelCoordinate(x: x, y: y)
                allPixels.insert(cooridinate)
            }
        }
        return allPixels.subtracting(nonMaskRegion)
    }
}

//
//  NoiseReductionTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/15.
//

import UIKit
import SwiftUI

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

        // 差分マスクを領域に分割し、ゴミ除去してノイズ除去
        var regions = await mask.getRegionSet(imageSize: imageSize)
        regions = regions.reduceSmallRegion()
        regions = try await regions.reduceSimillarRegion(leftImage: previewLeftCgImage, rightImage: previewRightCgImage)

        // 差分マスク外の領域を計算し、さらに反転して穴凹除去
        let reversedRegions = await regions.reverse(imageSize: imageSize)
        let largestReversedRegion = reversedRegions.getLargestRegion()
        let noiseRemovedRegions = await largestReversedRegion.reverse(size: imageSize)
        mask = ImageMask(regionSet: noiseRemovedRegions)

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
    func getRegionSet(imageSize: CGSize) async -> PixelRegionSet {
        var alreadyChecked = Set<PixelCoordinate>()
        var regions = PixelRegionSet(regions: [])

        // BFSで領域分割
        for coordinate in self.coordinates {
            if !self.coordinates.contains(coordinate) {
                continue
            }
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

private extension PixelRegionSet {
    func reduceSmallRegion() -> PixelRegionSet {
        let threthold = 1
        let largeRegions = self.regions.filter { $0.size > threthold }
        let regionCount = 100
        let top10Regions = largeRegions.sorted { $0.size > $1.size }.prefix(regionCount)
        return PixelRegionSet(regions: Set(top10Regions))
    }

    func reduceSimillarRegion(
        leftImage: CGImage,
        rightImage: CGImage
    ) async throws -> PixelRegionSet {
        let regionCount = 30
        var regionDistances: [(region: PixelRegion, distance: Double)] = []
        regionDistances.reserveCapacity(self.regions.count)

        for region in self.regions {
            let leftColor = try await region.averageColor(of: leftImage)
            let rightColor = try await region.averageColor(of: rightImage)
            let distance = leftColor.distance(from: rightColor)
            regionDistances.append((region, distance))
        }

        let topRegions = regionDistances
            .sorted { $0.distance > $1.distance }
            .prefix(regionCount)
            .map { $0.region }

        return PixelRegionSet(regions: Set(topRegions))
    }

    func getLargestRegion() -> PixelRegion {
        let largestRegion = self.regions.sorted { $0.size > $1.size }.first
        return largestRegion ?? .init()
    }

    func reverse(imageSize: CGSize) async -> PixelRegionSet {
        let width = Int(imageSize.width)
        let height = Int(imageSize.height)

        var reversedCoordinates = Set<PixelCoordinate>()
        reversedCoordinates.reserveCapacity(width * height)

        for y in 0..<height {
            for x in 0..<width {
                let coordinate = PixelCoordinate(x: x, y: y)
                reversedCoordinates.insert(coordinate)
            }
        }

        for region in regions {
            for coordinate in region.coordinates {
                reversedCoordinates.remove(coordinate)
            }
        }

        let imageMask = ImageMask(coordinates: reversedCoordinates)
        let regions = await imageMask.getRegionSet(imageSize: imageSize)
        return regions
    }
}

private extension PixelRegion {
    func reverse(size: CGSize) async -> PixelRegionSet {
        let width = Int(size.width)
        let height = Int(size.height)

        var reversedCoordinates = Set<PixelCoordinate>()
        reversedCoordinates.reserveCapacity(width * height - self.coordinates.count)

        for y in 0..<height {
            for x in 0..<width {
                let coordinate = PixelCoordinate(x: x, y: y)
                if !self.coordinates.contains(coordinate) {
                    reversedCoordinates.insert(coordinate)
                }
            }
        }

        let mask = ImageMask(coordinates: reversedCoordinates)
        let regions = await mask.getRegionSet(imageSize: size)
        return regions
    }

    func averageColor(of image: CGImage) async throws -> Rgb {
        let rgbGrid = try await RgbGrid(image)
        var totalR: CGFloat = 0, totalG: CGFloat = 0, totalB: CGFloat = 0
        for coordinate in self.coordinates {
            totalB += CGFloat(rgbGrid.pixel(coordinate).b)
            totalG += CGFloat(rgbGrid.pixel(coordinate).g)
            totalR += CGFloat(rgbGrid.pixel(coordinate).r)
        }
        let averageR = totalR / CGFloat(self.coordinates.count)
        let averageG = totalG / CGFloat(self.coordinates.count)
        let averageB = totalB / CGFloat(self.coordinates.count)
        return .init(r: averageR, g: averageG, b: averageB, a: 1)
    }
}

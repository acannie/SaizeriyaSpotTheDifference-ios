//
//  SplitAndResizeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit

struct SplitAndResizeTask: CreateImageTaskExecutable {
    let headerText: String = "2枚の絵に分割中"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let image) = imageSuite else {
            throw CreateImageTaskError.unexpectedError
        }
        var uiImage = image

        // 枠を切り落とし
        uiImage = image.normalized
        uiImage = try await uiImage.removeBorder()

        // 左右に分割
        let splitImage = try uiImage.splitImage()

        return .double(left: splitImage.left, right: splitImage.right)
    }
}

private extension UIImage {
    func splitImage() throws -> (left: UIImage, right: UIImage) {
        let width = self.size.width
        let height = self.size.height

        let leftRect = CGRect(x: 0, y: 0, width: width / 2, height: height)
        let rightRect = CGRect(x: width / 2, y: 0, width: width / 2, height: height)

        guard
            let leftImage = self.cropping(to: leftRect),
            let rightImage = self.cropping(to: rightRect) else {
            throw CreateImageTaskError.unexpectedError
        }

        return (leftImage, rightImage)
    }

    func removeBorder(
        thickness: Int = 5,
        step: Int = 10,
        tolerance: CGFloat = 0.3
    ) async throws -> UIImage {
        let rgbGrid = try await RgbGrid(self)

        // MARK: 各辺ごとに平均色を取得
        func averageColor(_ samples: [Rgb]) -> Rgb {
            let count = CGFloat(samples.count)
            let total = samples.reduce(Rgb(r: 0, g: 0, b: 0)) { acc, p in
                Rgb(
                    r: acc.r + p.r,
                    g: acc.g + p.g,
                    b: acc.b + p.b
                )
            }
            return Rgb(
                r: total.r / count,
                g: total.g / count,
                b: total.b / count
            )
        }

        // 上
        var topSamples: [Rgb] = []
        for y in 0..<thickness {
            for x in stride(from: 0, to: rgbGrid.width, by: step) {
                if x > rgbGrid.width {
                    break
                }
                topSamples.append(rgbGrid.pixel(x, y))
            }
        }

        // 下
        var bottomSamples: [Rgb] = []
        for y in (rgbGrid.height - thickness)..<rgbGrid.height {
            for x in stride(from: 0, to: rgbGrid.width, by: step) {
                if x > rgbGrid.width {
                    break
                }
                bottomSamples.append(rgbGrid.pixel(x, y))
            }
        }

        // 左
        var leftSamples: [Rgb] = []
        for x in 0..<thickness {
            for y in stride(from: 0, to: rgbGrid.height, by: step) {
                if y > rgbGrid.height {
                    break
                }
                leftSamples.append(rgbGrid.pixel(x, y))
            }
        }

        // 右
        var rightSamples: [Rgb] = []
        for x in (rgbGrid.width - thickness)..<rgbGrid.width {
            for y in stride(from: 0, to: rgbGrid.height, by: step) {
                if y > rgbGrid.height {
                    break
                }
                rightSamples.append(rgbGrid.pixel(x, y))
            }
        }

        let topColor = averageColor(topSamples)
        let bottomColor = averageColor(bottomSamples)
        let leftColor = averageColor(leftSamples)
        let rightColor = averageColor(rightSamples)

        func isNear(
            _ point: Rgb,
            _ base: Rgb
        ) -> Bool {
            let dr = pow(point.r - base.r, 2)
            let dg = pow(point.g - base.g, 2)
            let db = pow(point.b - base.b, 2)
            return sqrt(dr + dg + db) < tolerance
        }

        // MARK: 辺ごとに内側へ進む

        var top = 0
        while top < rgbGrid.height {
            let line = (0..<rgbGrid.width).map { rgbGrid.pixel($0, top) }
            if line.filter({ isNear($0, topColor) }).count > rgbGrid.width / 2 {
                top += 1
            } else {
                break
            }
        }

        var bottom = rgbGrid.height - 1
        while bottom >= 0 {
            let line = (0..<rgbGrid.width).map { rgbGrid.pixel($0, bottom) }
            if line.filter({ isNear($0, bottomColor) }).count > rgbGrid.width / 2 {
                bottom -= 1
            } else {
                break
            }
        }

        var left = 0
        while left < rgbGrid.width {
            let line = (top..<bottom).map { rgbGrid.pixel(left, $0) }
            if line.filter({ isNear($0, leftColor) }).count > (bottom-top) / 2 {
                left += 1
            } else {
                break
            }
        }

        var right = rgbGrid.width - 1
        while right >= 0 {
            let line = (top..<bottom).map { rgbGrid.pixel(right, $0) }
            if line.filter({ isNear($0, rightColor) }).count > (bottom-top) / 2 {
                right -= 1
            } else {
                break
            }
        }

        // MARK: クロップ

        let rect = CGRect(
            x: left,
            y: top,
            width: max(right - left + 1, 1),
            height: max(bottom - top + 1, 1)
        )

        guard let cropped = self.cgImage?.cropping(to: rect) else {
            throw CreateImageTaskError.unexpectedError
        }
        return UIImage(cgImage: cropped)
    }
}

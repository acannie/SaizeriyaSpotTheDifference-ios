//
//  SplitAndResizeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit

struct SplitAndResizeTask: CreateImageTaskExecutable {
    let headerText: String = "2枚の絵に分割中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let image) = imageSuite else {
            throw CreateImageTaskError.unexpectedError
        }

        // 枠を切り落とし
        let normalizedImage = image.normalized
        let borderRemovedImage = try await normalizedImage.removeBorder()

        // 左右に分割
        let splitImage = try borderRemovedImage.splitImage()

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
        guard let cg = self.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }

        let w = cg.width
        let h = cg.height

        guard let data = cg.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else {
            throw CreateImageTaskError.unexpectedError
        }

        func pixel(_ x: Int, _ y: Int) -> Rgb {
            let i = (y * w + x) * 4
            return .init(
                r: CGFloat(ptr[i]) / 255,
                g: CGFloat(ptr[i+1]) / 255,
                b: CGFloat(ptr[i+2]) / 255
            )
        }

        // ---- Step 1: 各辺ごとに平均色を取得 ----
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
            for x in stride(from: 0, to: w, by: step) {
                topSamples.append(pixel(x, y))
            }
        }

        // 下
        var bottomSamples: [Rgb] = []
        for y in (h - thickness)..<h {
            for x in stride(from: 0, to: w, by: step) {
                bottomSamples.append(pixel(x, y))
            }
        }

        // 左
        var leftSamples: [Rgb] = []
        for x in 0..<thickness {
            for y in stride(from: 0, to: h, by: step) {
                leftSamples.append(pixel(x, y))
            }
        }

        // 右
        var rightSamples: [Rgb] = []
        for x in (w - thickness)..<w {
            for y in stride(from: 0, to: h, by: step) {
                rightSamples.append(pixel(x, y))
            }
        }

        let topColor = averageColor(topSamples)
        let bottomColor = averageColor(bottomSamples)
        let leftColor = averageColor(leftSamples)
        let rightColor = averageColor(rightSamples)

        func isNear(_ p: Rgb,
                    _ base: Rgb) -> Bool {
            let dr = abs(p.r - base.r)
            let dg = abs(p.g - base.g)
            let db = abs(p.b - base.b)
            return (dr + dg + db) < tolerance
        }

        // ---- Step 2: 辺ごとに内側へ進む ----

        var top = 0
        while top < h {
            let line = (0..<w).map { pixel($0, top) }
            if line.filter { isNear($0, topColor) }.count > w / 2 {
                top += 1
            } else { break }
        }

        var bottom = h - 1
        while bottom >= 0 {
            let line = (0..<w).map { pixel($0, bottom) }
            if line.filter { isNear($0, bottomColor) }.count > w / 2 {
                bottom -= 1
            } else { break }
        }

        var left = 0
        while left < w {
            let line = (top..<bottom).map { pixel(left, $0) }
            if line.filter { isNear($0, leftColor) }.count > (bottom-top) / 2 {
                left += 1
            } else { break }
        }

        var right = w - 1
        while right >= 0 {
            let line = (top..<bottom).map { pixel(right, $0) }
            if line.filter { isNear($0, rightColor) }.count > (bottom-top) / 2 {
                right -= 1
            } else { break }
        }

        // ---- Step 3: クロップ ----

        let rect = CGRect(
            x: left,
            y: top,
            width: max(right - left + 1, 1),
            height: max(bottom - top + 1, 1)
        )

        guard let cropped = cg.cropping(to: rect) else {
            throw CreateImageTaskError.unexpectedError
        }
        return UIImage(cgImage: cropped)
    }
}

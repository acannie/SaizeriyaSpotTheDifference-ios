//
//  RgbGrid.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/25.
//

import UIKit

struct RgbGrid {
    let value: [[Rgb]]
    let width: Int
    let height: Int

    init(_ value: [[Rgb]]) throws {
        guard let firstRowCount = value.first?.count else {
            self.value = value
            self.width = 0
            self.height = 0
            return
        }
        for row in value {
            if row.count != firstRowCount {
                throw RgbGridError.gridRowSizeIsNotEven
            }
        }
        self.value = value
        self.width = firstRowCount
        self.height = value.count
    }

    init(_ uiImage: UIImage) async throws {
        guard let cgImage = uiImage.cgImage,
              let data = cgImage.dataProvider?.data else {
            throw RgbGridError.unexpectedError
        }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let imageData = UnsafeMutablePointer<UInt8>.allocate(
            capacity: width * height * bytesPerPixel
        )

        // 画像をレンダリング
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: imageData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw RgbGridError.unexpectedError
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // 色の配列に変形
        var rgbRows: [[Rgb]] = []
        for pixelY in 0..<height {
            var row: [Rgb] = []
            for pixelX in 0..<width {
                let offset = (pixelY * width + pixelX) * bytesPerPixel
                let red = CGFloat(imageData[offset]) / 255.0
                let green = CGFloat(imageData[offset + 1]) / 255.0
                let blue = CGFloat(imageData[offset + 2]) / 255.0
                _ = CGFloat(imageData[offset + 3]) / 255.0
                let color = Rgb(r: red, g: green, b: blue)
                row.append(color)
            }
            rgbRows.append(row)
        }

        // メモリ解放
        imageData.deallocate()

        // プロパティの値をセット
        self.value = rgbRows
        self.width = width
        self.height = height
    }

    func pixel(_ x: Int, _ y: Int) -> Rgb {
        value[y][x]
    }

    func pixel(_ coordinate: ImageCoordinate) -> Rgb {
        value[coordinate.y][coordinate.x]
    }

    func image() async throws -> UIImage? {
        // bitmap context の準備
        let size = CGSize(width: self.width, height: self.height)
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        // contextの各ピクセルに色をセット
        for (pixelY, row) in value.enumerated() {
            for (pixelX, color) in row.enumerated() {
                context.setFillColor(UIColor(
                    red: color.r,
                    green: color.g,
                    blue: color.b,
                    alpha: 1.0
                ).cgColor)
                context.fill(CGRect(x: pixelX, y: pixelY, width: 1, height: 1))
            }
        }

        // contextから画像を生成
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
}

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

    init(_ cgImage: CGImage) async throws {
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
                let alpha = CGFloat(imageData[offset + 3]) / 255.0
                let color = Rgb(r: red, g: green, b: blue, a: alpha)
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

    func pixel(_ coordinate: PixelCoordinate) -> Rgb {
        value[coordinate.y][coordinate.x]
    }

    func makeCGImage() throws -> CGImage {
        let height = value.count
        guard height > 0 else {
            throw RgbGridError.unexpectedError
        }
        let width = value[0].count

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8

        var data = [UInt8](repeating: 0, count: width * height * bytesPerPixel)

        for y in 0..<height {
            for x in 0..<width {
                let rgb = value[y][x]
                let offset = y * bytesPerRow + x * bytesPerPixel

                data[offset + 0] = UInt8(clamping: Int(rgb.r * 255))
                data[offset + 1] = UInt8(clamping: Int(rgb.g * 255))
                data[offset + 2] = UInt8(clamping: Int(rgb.b * 255))
                data[offset + 3] = UInt8(clamping: Int(rgb.a * 255))
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &data,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw RgbGridError.unexpectedError
        }

        guard let cgImage = context.makeImage() else {
            throw RgbGridError.unexpectedError
        }
        return cgImage
    }
}

//
//  CreateImageTaskExecutable.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import CoreImage

protocol CreateImageTaskExecutable {
    var headerText: String { get }
    func createImage(from imageSuite: ImageSuite) async throws -> ImageSuite
    func ciImageToRGBA8(
        _ ciImage: CIImage,
        context: CIContext,
        targetSize: CGSize?
    ) -> (
        data: [UInt8],
        width: Int,
        height: Int
    )?
}

extension CreateImageTaskExecutable {
    func ciImageToRGBA8(
        _ ciImage: CIImage,
        context: CIContext,
        targetSize: CGSize? = nil
    ) -> (
        data: [UInt8],
        width: Int,
        height: Int
    )? {
        let image = if targetSize != nil {
            ciImage.transformed(
                by: CGAffineTransform(
                    scaleX: targetSize!.width/ciImage.extent.width,
                    y: targetSize!.height/ciImage.extent.height
                )
            )
        } else {
            ciImage
        }
        let width = Int(image.extent.width)
        let height = Int(image.extent.height)
        let rowBytes = width * 4
        var pixelData = [UInt8](repeating: 0, count: rowBytes * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        guard let cgImage = CIContext(options: nil).createCGImage(image, from: image.extent),
              let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: rowBytes,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return nil
        }

        context.draw(
            cgImage,
            in: CGRect(x: 0, y: 0, width: width, height: height)
        )
        return (pixelData, width, height)
    }
}

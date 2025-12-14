//
//  SplitAndResizeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit

struct SplitAndResizeTask: CreateImageTaskExecutable {
    let headerText: String = "2枚の絵に分割中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let image) = imageSuite.processing,
              case .single(let previewImage) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }
        var cgImage = try getCgImage(from: image)
        var previewCgImage = try getCgImage(from: previewImage)

        // 枠を切り落とし
        let borderPixels = 7
        cgImage = try await cgImage.removeBorder(by: borderPixels)
        previewCgImage = try await previewCgImage.removeBorder(by: borderPixels)

        // 左右に分割
        let splitedImages = try cgImage.splitImage()
        let splitedPreviewImages = try previewCgImage.splitImage()

        return .init(
            processing: .pair(.cg(splitedImages.left, splitedImages.right)),
            preview: .pair(.cg(splitedPreviewImages.left, splitedPreviewImages.right)),
            result: nil
        )
    }
}

private extension CGImage {
    func removeBorder(by pixels: Int) async throws -> CGImage {
        let rect = CGRect(
            x: pixels,
            y: pixels,
            width: self.width - pixels * 2,
            height: self.height - pixels * 2
        )

        guard rect.width > 0, rect.height > 0,
            let croppedCgImage = self.cropping(to: rect) else {
            throw CreateImageTaskError.unexpectedError
        }

        return croppedCgImage
    }

    func splitImage() throws -> (left: CGImage, right: CGImage) {
        let width = self.width
        let height = self.height

        let leftRect = CGRect(x: 0, y: 0, width: width / 2, height: height)
        let rightRect = CGRect(x: width / 2, y: 0, width: width / 2, height: height)

        guard
            let leftImage = self.cropping(to: leftRect),
            let rightImage = self.cropping(to: rightRect) else {
            throw CreateImageTaskError.unexpectedError
        }

        return (leftImage, rightImage)
    }
}

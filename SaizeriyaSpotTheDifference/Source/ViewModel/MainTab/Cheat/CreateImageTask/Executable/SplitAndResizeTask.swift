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
        guard case .singleCiImage(let ciImage) = imageSuite.processing,
              case .singleCiImage(let previewCiImage) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }

        let ciContext = CIContext()
        var cgImage = try ciImage.createCgImage(with: ciContext)
        var previewCgImage = try previewCiImage.createCgImage(with: ciContext)

        // 枠を切り落とし
        cgImage = try await cgImage.removeBorder(by: 10)
        previewCgImage = try await previewCgImage.removeBorder(by: 10)

        // 左右に分割
        let splitedImages = try cgImage.splitImage()
        let splitedPreviewImages = try previewCgImage.splitImage()

        return .init(
            processing: .doubleCgImage(left: splitedImages.left, right: splitedImages.right),
            preview: .doubleCgImage(left: splitedPreviewImages.left, right: splitedPreviewImages.right),
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

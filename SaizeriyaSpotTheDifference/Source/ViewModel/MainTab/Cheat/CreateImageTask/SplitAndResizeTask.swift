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

        let normalizedImage = image.normalized
        let splitImage = try normalizedImage.splitImage()

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
}

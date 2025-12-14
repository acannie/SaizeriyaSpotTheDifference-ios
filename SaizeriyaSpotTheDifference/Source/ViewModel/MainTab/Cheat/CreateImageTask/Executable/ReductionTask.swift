//
//  ReductionTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/30.
//

import UIKit
import PhotosUI
import SwiftUI

struct ReductionTask: CreateImageTaskExecutable {
    let headerText: String = "画像サイズを調整中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .singleCiImage(var ciImage) = imageSuite.processing else {
            throw CreateImageTaskError.unexpectedError
        }

        ciImage = ciImage.reduction(targetHeight: 300)

        return .init(
            processing: .singleCiImage(ciImage),
            preview: .singleCiImage(ciImage),
            result: nil
        )
    }
}

private extension CIImage {
    func reduction(targetHeight: CGFloat) -> CIImage {
        let originalHeight = self.extent.height
        let scale = targetHeight / originalHeight

        guard scale < 1.0 else {
            return self
        }

        let transform = CGAffineTransform(scaleX: scale, y: scale)
        return self.transformed(by: transform)
    }
}

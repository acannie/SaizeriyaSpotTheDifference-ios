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

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(var uiImage) = imageSuite else {
            throw CreateImageTaskError.unexpectedError
        }

        uiImage = await uiImage.reduction(height: 300)

        return .single(uiImage)
    }
}

private extension UIImage {
    func reduction(height: CGFloat) async -> UIImage {
        let targetHeight: CGFloat = 300
        let originalSize = self.size
        let scale = targetHeight / originalSize.height
        if scale > 1.0 {
            return self
        }
        let newSize = CGSize(width: originalSize.width * scale, height: targetHeight)

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let uiImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return uiImage
    }
}

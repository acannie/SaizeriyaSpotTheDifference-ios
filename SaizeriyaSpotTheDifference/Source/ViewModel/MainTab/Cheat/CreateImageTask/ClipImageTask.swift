//
//  ClipImageTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit
import AVFoundation

struct ClipImageTask: CreateImageTaskExecutable {
    var headerText: String = "撮影範囲を計算中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
//        guard case .single(let uiImage) = imageSuite else {
//            throw CreateImageTaskError.unexpectedError
//        }
//
//        let previewLayer: AVCaptureVideoPreviewLayer = camera.previewLayer
//        let image: UIImage
//
//        let metadata = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
//
//
//
//        let cropped = cropImage(uiImage, with: metadata)

        return imageSuite
    }
}

private extension ClipImageTask {
    func cropImage(_ image: UIImage, with rect: CGRect) -> UIImage {
        let width = image.size.width * rect.width
        let height = image.size.height * rect.height
        let x = image.size.width * rect.origin.x
        let y = image.size.height * rect.origin.y
        let croppingRect = CGRect(x: x, y: y, width: width, height: height)

        guard let cgImage = image.cgImage?.cropping(to: croppingRect) else {
            return image
        }
        return UIImage(cgImage: cgImage)
    }
}

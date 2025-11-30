//
//  ClipImageTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit
import AVFoundation

struct ClipImageTask: CreateImageTaskExecutable {
    let layoutHeight: LayoutHeight
    let cameraPreviewFooterHeight: CGFloat
    var headerText: String = "撮影範囲を計算中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let image) = imageSuite.forProcessing else {
            throw CreateImageTaskError.unexpectedError
        }

        // プレビューと画像のサイズ比率
        let scale = image.size.width / UIScreen.main.bounds.width

        guard let previewedImage = getPreviewedImage(from: image, scale: scale) else {
            throw CreateImageTaskError.unexpectedError
        }

        return .init(
            forProcessing: .single(previewedImage),
            forPreview: .single(previewedImage),
            result: nil
        )
    }
}

private extension ClipImageTask {
    func getPreviewedImage(from image: UIImage, scale: CGFloat) -> UIImage? {
        // x座標は0
        let originX: CGFloat = 0

        // y座標を計算
        let headerHeight = layoutHeight.headerHeight
        let contentHeight = layoutHeight.contentHeight
        let cameraPreviewHeight = contentHeight - cameraPreviewFooterHeight
        let originY = headerHeight

        // トリミング開始地点
        let cropRect = CGRect(
            x: originX * scale,
            y: originY * scale,
            width: UIScreen.main.bounds.width * scale,
            height: cameraPreviewHeight * scale
        )

        return image.cropping(to: cropRect)
    }
}

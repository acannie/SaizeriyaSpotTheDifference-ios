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
        guard case .single(let image) = imageSuite.processing else {
            throw CreateImageTaskError.unexpectedError
        }
        var cgImage = try getCgImage(from: image)

        // プレビューと画像のサイズ比率
        let scale = CGFloat(cgImage.width) / UIScreen.main.bounds.width

        cgImage = try await cgImage.previewedImage(
            scale: scale,
            layoutHeight: layoutHeight,
            cameraPreviewFooterHeight: cameraPreviewFooterHeight
        )

        return .init(
            processing: .single(.cg(cgImage)),
            preview: .single(.cg(cgImage)),
            result: nil
        )
    }
}

private extension CGImage {
    func previewedImage(
        scale: CGFloat,
        layoutHeight: LayoutHeight,
        cameraPreviewFooterHeight: CGFloat
    ) async throws -> CGImage {
        // x座標は0
        let originX: CGFloat = 0

        // y座標を計算
        let headerHeight = layoutHeight.headerHeight
        let contentHeight = layoutHeight.contentHeight
        let cameraPreviewHeight = contentHeight - cameraPreviewFooterHeight
        let originY = headerHeight * scale

        // トリミング開始地点
        let cropRect = CGRect(
            x: originX * scale,
            y: originY * scale,
            width: UIScreen.main.bounds.width * scale,
            height: cameraPreviewHeight * scale
        )

        guard let cropped = self.cropping(to: cropRect) else {
            throw CreateImageTaskError.unexpectedError
        }

        return cropped
    }
}

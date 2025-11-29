//
//  DetectRectangleAndPerspectiveCorrectTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
@preconcurrency import Vision

struct DetectRectangleAndPerspectiveCorrectTask: CreateImageTaskExecutable {
    let headerText: String = "間違い探しを検出中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let uiImage) = imageSuite,
              let cgImage = uiImage.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 画像の形式変換
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)

        // メニューブックの輪郭を特定
        let detectedRect = try await cgImage.detectRect()

        // 矩形補正
        let perspectiveCorrectedCiImage = ciImage.perspectiveCorrect(rect: detectedRect)
        let perspectiveCorrectedCgImage = try perspectiveCorrectedCiImage.createCgImage(with: context)

        // 返却値の作成
        let resultImage = UIImage(
            cgImage: perspectiveCorrectedCgImage,
            scale: uiImage.scale,
            orientation: uiImage.imageOrientation
        )

        return .single(resultImage)
    }
}

private struct Rect {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
}

private extension CGImage {
    func detectRect() async throws -> Rect {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                guard error == nil,
                      let obs = request.results?.compactMap({ $0 as? VNRectangleObservation }).first else {
                    continuation.resume(throwing: CreateImageTaskError.couldnotDetectMenuBook)
                    return
                }

                let size = CGSize(width: self.width, height: self.height)
                let rect = Rect(
                    topLeft: obs.topLeft.toImagePoint(size: size),
                    topRight: obs.topRight.toImagePoint(size: size),
                    bottomLeft: obs.bottomLeft.toImagePoint(size: size),
                    bottomRight: obs.bottomRight.toImagePoint(size: size)
                )

                continuation.resume(returning: rect)
            }

            request.minimumConfidence = 0.7
            request.maximumObservations = 1

            let handler = VNImageRequestHandler(cgImage: self, options: [:])
            DispatchQueue.global().async {
                try? handler.perform([request])
            }
        }
    }
}

private extension CIImage {
    /// エッジを強調
    func emphasizeEdge() -> CIImage {
        // エッジ抽出
        let edges = CIFilter(name: "CIEdges")!
        edges.setDefaults()
        edges.setValue(self, forKey: kCIInputImageKey)
        let edgeImage = edges.outputImage!

        // 形態学的膨張で線を太らせる
        let dilate = CIFilter(name: "CIMorphologyMaximum")!
        dilate.setValue(edgeImage, forKey: kCIInputImageKey)
        dilate.setValue(5.0, forKey: "inputRadius")
        let dilateImage = dilate.outputImage!

        return dilateImage
    }

    /// 矩形補正
    func perspectiveCorrect(rect: Rect) -> CIImage {
        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = self
        filter.topLeft = rect.topLeft
        filter.topRight = rect.topRight
        filter.bottomLeft = rect.bottomLeft
        filter.bottomRight = rect.bottomRight

        return filter.outputImage!
    }

    /// グレースケール
    func grayscale() -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = self
        filter.saturation = 0

        return filter.outputImage!
    }

    /// コントラスト強調
    func highContrast() -> CIImage {
        let filter = CIFilter.colorControls()
        filter.inputImage = self
        filter.contrast = 1.4

        return filter.outputImage!
    }
}

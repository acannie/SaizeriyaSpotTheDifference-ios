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
    let headerText: String = "間違い探しを検出中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .singleCgImage(var cgImage) = imageSuite.processing else {
            throw CreateImageTaskError.unexpectedError
        }

        // メニューブックの輪郭を特定
        let detectedRect = try await cgImage.detectRect()

        // 矩形補正
        var ciImage = CIImage(cgImage: cgImage)
        ciImage = ciImage.perspectiveCorrect(rect: detectedRect)

        return .init(
            processing: .singleCiImage(ciImage),
            preview: .singleCiImage(ciImage),
            result: nil
        )
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
}

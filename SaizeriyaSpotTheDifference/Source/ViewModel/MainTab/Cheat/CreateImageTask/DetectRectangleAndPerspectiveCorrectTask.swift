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

        let resultImage: UIImage? = try await withCheckedThrowingContinuation { continuation in
            let request = VNDetectRectanglesRequest { request, error in
                guard error == nil,
                      let obs = request.results?.compactMap({ $0 as? VNRectangleObservation }).first else {
                    continuation.resume(returning: nil)
                    return
                }

                let ciImage = CIImage(
                    cgImage: cgImage,
                    options: [.applyOrientationProperty: true]
                )
                .oriented(forExifOrientation: Int32(uiImage.imageOrientation.rawValue))
                let size = CGSize(width: ciImage.extent.width, height: ciImage.extent.height)

                let filter = CIFilter.perspectiveCorrection()
                filter.inputImage = ciImage
                filter.topLeft = toImagePoint(obs.topLeft, size: size)
                filter.topRight = toImagePoint(obs.topRight, size: size)
                filter.bottomLeft = toImagePoint(obs.bottomLeft, size: size)
                filter.bottomRight = toImagePoint(obs.bottomRight, size: size)

                let context = CIContext()
                guard let outputCI = filter.outputImage else {
                    continuation.resume(returning: nil)
                    return
                }

                guard let outCG = context.createCGImage(outputCI, from: outputCI.extent) else {
                    continuation.resume(returning: nil)
                    return
                }

                continuation.resume(returning: UIImage(cgImage: outCG))
            }

            request.minimumConfidence = 0.7
            request.maximumObservations = 1

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            DispatchQueue.global().async {
                try? handler.perform([request])
            }
        }

        guard let resultImage else {
            throw CreateImageTaskError.couldnotDetectMenuBook
        }
        return .single(resultImage)
    }
}

private extension DetectRectangleAndPerspectiveCorrectTask {
    func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        return hypot(a.x - b.x, a.y - b.y)
    }

    func cgImagePropertyOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up: .up
        case .down: .down
        case .left: .left
        case .right: .right
        case .upMirrored: .upMirrored
        case .downMirrored: .downMirrored
        case .leftMirrored: .leftMirrored
        case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }

    func toImagePoint(_ p: CGPoint, size: CGSize) -> CGPoint {
        .init(x: p.x * size.width, y: p.y * size.height)
    }
}

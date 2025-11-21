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

                let ciImage = CIImage(cgImage: cgImage)
                let size = CGSize(width: ciImage.extent.width, height: ciImage.extent.height)

                let filter = CIFilter.perspectiveCorrection()
                filter.inputImage = ciImage
                filter.topLeft = obs.topLeft.toImagePoint(size: size)
                filter.topRight = obs.topRight.toImagePoint(size: size)
                filter.bottomLeft = obs.bottomLeft.toImagePoint(size: size)
                filter.bottomRight = obs.bottomRight.toImagePoint(size: size)

                let context = CIContext()
                guard let outputCI = filter.outputImage else {
                    continuation.resume(returning: nil)
                    return
                }

                guard let outCG = context.createCGImage(outputCI, from: outputCI.extent) else {
                    continuation.resume(returning: nil)
                    return
                }

                let resultImage = UIImage(
                    cgImage: outCG,
                    scale: uiImage.scale,
                    orientation: uiImage.imageOrientation
                )
                continuation.resume(returning: resultImage)
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

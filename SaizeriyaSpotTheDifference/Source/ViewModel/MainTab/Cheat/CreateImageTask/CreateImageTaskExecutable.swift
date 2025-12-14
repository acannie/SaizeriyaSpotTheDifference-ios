//
//  CreateImageTaskExecutable.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import CoreImage

protocol CreateImageTaskExecutable {
    var headerText: String { get }
    func process(from imageSuite: ImageSuite) async throws -> ImageSuite
    func getCgImage(from imageFormat: ImagePayload.Image) throws -> CGImage
    func getCiImage(from imageFormat: ImagePayload.Image) throws -> CIImage
    func getCgImagePair(from imagePairFormat: ImagePayload.ImagePair) throws -> (CGImage, CGImage)
    func getCiImagePair(from imagePairFormat: ImagePayload.ImagePair) throws -> (CIImage, CIImage)
}

extension CreateImageTaskExecutable {
    func getCgImage(from imageFormat: ImagePayload.Image) throws -> CGImage {
        switch imageFormat {
        case .cg(let cgImage):
            cgImage
        case .ci(let ciImage):
            try ciImage.createCgImage()
        }
    }

    func getCiImage(from imageFormat: ImagePayload.Image) throws -> CIImage {
        switch imageFormat {
        case .cg(let cgImage):
            CIImage(cgImage: cgImage)
        case .ci(let ciImage):
            ciImage
        }
    }

    func getCgImagePair(from imagePairFormat: ImagePayload.ImagePair) throws -> (CGImage, CGImage) {
        switch imagePairFormat {
        case .cg(let cgImageLeft, let cgImageRight):
            (cgImageLeft, cgImageRight)
        case .ci(let ciImageLeft, let ciImageRight):
            (try ciImageLeft.createCgImage(), try ciImageRight.createCgImage())
        }
    }

    func getCiImagePair(from imagePairFormat: ImagePayload.ImagePair) throws -> (CIImage, CIImage) {
        switch imagePairFormat {
        case .cg(let cgImageLeft, let cgImageRight):
            (CIImage(cgImage: cgImageLeft), CIImage(cgImage: cgImageRight))
        case .ci(let ciImageLeft, let ciImageRight):
            (ciImageLeft, ciImageRight)
        }
    }
}

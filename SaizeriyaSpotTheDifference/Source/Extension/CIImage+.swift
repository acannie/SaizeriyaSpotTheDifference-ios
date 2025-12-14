//
//  CIImage+.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/25.
//

import CoreImage

extension CIImage {
    func createCgImage() throws -> CGImage {
        let context = CIContext()
        guard let cgImage = context.createCGImage(self, from: self.extent) else {
            throw CreateImageTaskError.unexpectedError
        }
        return cgImage
    }
}

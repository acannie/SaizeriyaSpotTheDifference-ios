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
}

extension CreateImageTaskExecutable {
    
}

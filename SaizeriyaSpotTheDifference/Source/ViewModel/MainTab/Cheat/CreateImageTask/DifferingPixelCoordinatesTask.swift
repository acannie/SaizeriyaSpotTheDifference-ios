//
//  DifferingPixelCoordinatesTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

struct DifferingPixelCoordinatesTask: CreateImageTaskExecutable {
    let headerText: String = "差分を検出中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        try? await Task.sleep(for: .seconds(1))
        return imageSuite
    }
}

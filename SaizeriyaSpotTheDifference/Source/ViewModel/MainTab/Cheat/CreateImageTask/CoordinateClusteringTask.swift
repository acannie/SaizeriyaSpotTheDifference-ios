//
//  CoordinateClusteringTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

struct CoordinateClusteringTask: CreateImageTaskExecutable {
    let headerText: String = "間違いを分類中……"

    func createImage(from imageSuite: ImageSuite) async throws -> ImageSuite {
        try? await Task.sleep(for: .seconds(1))
        return imageSuite
    }
}

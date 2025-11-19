//
//  CreateImageTaskError.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

enum CreateImageTaskError: Error {
    case couldnotDetectBook

    var localizedDescription: String {
        switch self {
        case .couldnotDetectBook:
            "間違い探しを検出できませんでした"
        }
    }
}

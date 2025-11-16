//
//  MainTab.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

enum MainTab: CaseIterable {
    case cheat
    case collection
    case environmentSetting

    var text: String {
        switch self {
        case .cheat:
            "差分\n検出"
        case .collection:
            "コレク\nション"
        case .environmentSetting:
            "環境\n設定"
        }
    }
}

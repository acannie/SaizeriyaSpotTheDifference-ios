//
//  LogomarkView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct LogomarkView: View {
    private let firstEllipseSize = CGSize(width: 260, height: 160)
    private let secondEllipseSize = CGSize(width: 250, height: 150)
    private let bottomFillHeight: CGFloat = 40

    private var overlayRectangleHeight: CGFloat {
        secondEllipseSize.height - bottomFillHeight
    }
    private var overlayRectangleOffsetY: CGFloat {
        let distanceFromEllipseCenterToBottomFill = (secondEllipseSize.height / 2) - bottomFillHeight
        return (overlayRectangleHeight / 2) - distanceFromEllipseCenterToBottomFill
    }
    private let mTextBackgroundSize = CGSize(width: 90, height: 95)

    var body: some View {
        ZStack {
            // 下部の塗りつぶし緑
            Ellipse()
                .fill(.commonGreen)
                .frame(width: secondEllipseSize.width, height: secondEllipseSize.height)
            // 塗りつぶし緑を覆う背景色の長方形
            Rectangle()
                .fill(.commonPrimary)
                .frame(width: secondEllipseSize.width, height: overlayRectangleHeight)
                .offset(y: -overlayRectangleOffsetY)
            // Mの文字
            mText
            // 文字間の線
            Capsule()
                .foregroundStyle(.commonRed)
                .frame(width: 160, height: 5)
                .offset(x: 30, y: 20)
            // 大きな文字
            HStack(spacing: 0) {
                ForEach(Array("𝐚𝐜𝐡𝐢𝐠𝐚𝐢").enumerated().map { $0 }, id: \.offset) { _, char in
                    ZStack {
                        if char == "𝐠" {
                            Text(String(char))
                                .foregroundStyle(.commonPrimary)
                                .font(.system(size: 45))
                                .offset(x: 2, y: 2)
                        }
                        Text(String(char))
                            .foregroundStyle(.commonRed)
                            .font(.system(size: 45))
                    }
                }
            }
            .offset(x: 26, y: -3)
            // 小さな文字
            Text("SAGASOUZE EVERYONE")
                .foregroundStyle(.commonRed)
                .font(.system(size: 10, weight: .semibold))
                .offset(x: 15, y: 28)
            mark
                .offset(y: -45)
            // 外側の楕円
            Ellipse()
                .stroke(.commonGreen, lineWidth: 3)
                .frame(width: firstEllipseSize.width, height: firstEllipseSize.height)
            // 内側の楕円
            Ellipse()
                .stroke(.commonGreen, lineWidth: 2)
                .frame(width: secondEllipseSize.width, height: secondEllipseSize.height)
        }
    }
}

private extension LogomarkView {
    var mText: some View {
        ZStack {
            // 背景色
            Ellipse()
                .fill(.commonPrimary)
                .frame(width: mTextBackgroundSize.width, height: mTextBackgroundSize.height)
            // 文字本体
            Text("𝐌")
                .foregroundStyle(.commonRed)
                .font(.system(size: 60))
                .offset(y: -5)
            // 下の赤い線
            Ellipse()
                .trim(from: 0.08, to: 0.42)
                .stroke(.commonRed, lineWidth: 5)
                .frame(width: mTextBackgroundSize.width - 15, height: mTextBackgroundSize.height - 15)
            // 赤い線左端の角丸
            Circle()
                .fill(.commonRed)
                .frame(width: 5, height: 5)
                .offset(x: -33, y: 19)
        }
        .offset(x: -80)
    }

    var mark: some View {
        ZStack {
            Group {
                Ellipse()
                    .trim(from: 0.0, to: 0.5)
                    .fill(.commonGreen)
                Ellipse()
                    .stroke(.commonGreen, lineWidth: 1)
            }
            .frame(width: 35, height: 40)
            ForEach(Side.allCases, id: \.self) { side in
                Image(systemName: "crown.fill")
                    .resizable()
                    .foregroundStyle(.commonGreen)
                    .frame(width: 15, height: 5)
                    .rotationEffect(.degrees(side.unit * 15))
                    .offset(x: side.unit * 5)
            }
            .offset(y: -24)
            ForEach(Side.allCases, id: \.self) { side in
                Image(systemName: side.isLeft ? "laurel.leading" : "laurel.trailing")
                    .resizable()
                    .fontWeight(.black)
                    .foregroundStyle(.commonGreen)
                    .frame(width: 10, height: 30)
                    .rotationEffect(.degrees(side.unit * 20))
                    .offset(x: side.unit * 20, y: 10)
            }
            Group {
                Image(systemName: "book.fill")
                    .resizable()
                    .foregroundStyle(.commonPrimary)
                    .frame(width: 20, height: 15)
                Image(systemName: "book")
                    .resizable()
                    .foregroundStyle(.commonGreen)
                    .frame(width: 19, height: 14)
            }
            .offset(x: -4, y: 0)
            Group {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.black)
                    .foregroundStyle(.commonPrimary)
                    .frame(width: 16, height: 16)
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundStyle(.commonGreen)
                    .frame(width: 14, height: 14)
            }
            .offset(x: 7, y: 7)
            Image(systemName: "questionmark")
                .resizable()
                .foregroundStyle(.commonGreen)
                .frame(width: 5, height: 8)
                .offset(y: -13)
        }
    }
}

#Preview {
    LogomarkView()
}

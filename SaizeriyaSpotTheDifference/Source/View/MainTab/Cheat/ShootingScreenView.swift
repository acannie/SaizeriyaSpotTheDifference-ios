//
//  ShootingScreenView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI

struct ShootingScreenView: View {
    @State private var image: UIImage?
    @Binding private var topBarText: String
    @StateObject private var camera = CameraManager()
    private var guideLineSize: CGSize {
        let horizontalPadding: CGFloat = 10
        let width = UIScreen.main.bounds.width - horizontalPadding * 2
        let height = width / 2
        return .init(width: width, height: height)
    }

    init(topBarText: Binding<String>) {
        self._topBarText = topBarText
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                CameraPreview(session: camera.session)
                guideLine
            }
            footer
        }
        .onChange(of: camera.capturedImage) {
            if let image = camera.capturedImage {
                self.image = image
            }
        }
        .onAppear {
            topBarText = "間違い探しを撮影しよう"
        }
    }
}

private extension ShootingScreenView {
    var footer: some View {
        HStack {
            shootingButton
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .background(.black)
    }

    var shootingButton: some View {
        Button(
            action: {
                camera.takePhoto()
            }
        ) {
            Circle()
                .fill(.white.opacity(0.9))
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 4)
                        .frame(width: 90, height: 90)
                )
                .shadow(radius: 4)
        }
    }

    var guideLine: some View {
        ZStack {
            // 枠
            Rectangle()
                .stroke(.white, lineWidth: 2)
                .frame(width: guideLineSize.width, height: guideLineSize.height)
            // 中央の線
            Rectangle()
                .fill(.white)
                .frame(width: 2, height: guideLineSize.height)
        }
    }
}

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
    private let guideLineWidth: CGFloat = 2
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
        ZStack {
            CameraPreview(session: camera.session)
            VStack {
                Spacer()
                guideLine
                Spacer()
                footer
            }
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
        .background(.cameraBackground)
    }

    var shootingButton: some View {
        Button(
            action: {
                camera.takePhoto()
            }
        ) {
            ZStack {
                Circle()
                    .fill(.shutterButtonOutline)
                    .frame(width: 90, height: 90)
                Circle()
                    .fill(.shutterButtonFill)
                    .frame(width: 75, height: 75)
            }
            .shadow(radius: 4)
        }
    }

    var guideLine: some View {
        ZStack {
            // 枠
            Rectangle()
                .stroke(.cameraGuideLine, lineWidth: guideLineWidth)
                .frame(width: guideLineSize.width, height: guideLineSize.height)
            // 中央の線
            Rectangle()
                .fill(.cameraGuideLine)
                .frame(width: guideLineWidth, height: guideLineSize.height - guideLineWidth * 2)
        }
    }
}

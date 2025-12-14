//
//  CameraManager.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import AVFoundation
import Combine
import SwiftUI

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published private(set) var capturedImage: CGImage?

    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()

    override init() {
        super.init()
        configureSessionAsync()
    }

    private func configureSessionAsync() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()

            // 入力デバイス
            if let camera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back),
               let input = try? AVCaptureDeviceInput(device: camera),
               self.session.canAddInput(input) {
                self.session.addInput(input)
            }

            // 出力デバイス
            if self.session.canAddOutput(self.output) {
                self.session.addOutput(self.output)
            }

            self.session.commitConfiguration()
        }
    }

    func startRunning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.session.startRunning()
        }
    }

    func stopRunning() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            self.session.stopRunning()
        }
    }

    /// 撮影
    func takePhoto() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    /// 撮影コールバック
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard error == nil else { return }

        guard
            let data = photo.fileDataRepresentation(),
            let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, 0, nil),
            let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
            let orientationRaw = properties[kCGImagePropertyOrientation] as? UInt32,
            let orientation = CGImagePropertyOrientation(rawValue: orientationRaw)
        else {
            return
        }

        let ciImage = CIImage(cgImage: cgImage)
            .oriented(orientation)
        let context = CIContext()
        guard let fixedCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        DispatchQueue.main.async {
            self.capturedImage = fixedCGImage
        }
    }
}

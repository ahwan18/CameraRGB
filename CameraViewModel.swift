//
//  CameraViewModel.swift
//  CameraRGBTest
//
//  Created by Ahmad Kurniawan Ibrahim on 06/05/25.
//


import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detectedColor: (r: Int, g: Int, b: Int)?
    let session = AVCaptureSession()

    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "CameraQueue")
    private var isCapturing = false

    func configure() {
        session.beginConfiguration()
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input),
              session.canAddOutput(output) else {
            return
        }

        session.addInput(input)
        output.setSampleBufferDelegate(self, queue: queue)
        session.addOutput(output)
        session.commitConfiguration()
        session.startRunning()
    }

    func startCapturingColor() {
        isCapturing = true
    }

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard isCapturing,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        let centerRect = CGRect(x: ciImage.extent.midX - 5, y: ciImage.extent.midY - 5, width: 10, height: 10)

        if let cropped = ciImage.cropped(to: centerRect),
           let cgImage = context.createCGImage(cropped, from: cropped.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            if let color = uiImage.averageColor {
                DispatchQueue.main.async {
                    self.detectedColor = (Int(color.redValue * 255), Int(color.greenValue * 255), Int(color.blueValue * 255))
                }
            }
        }
    }
}

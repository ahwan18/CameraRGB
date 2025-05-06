import AVFoundation
import UIKit

class CameraViewModel: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var detectedColor: (r: Int, g: Int, b: Int)?
    let session = AVCaptureSession()

    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "CameraQueue")
    private var lastUpdate = Date()

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

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Batasi update warna setiap 0.3 detik agar tidak terlalu cepat
        let now = Date()
        guard now.timeIntervalSince(lastUpdate) > 0.3 else { return }
        lastUpdate = now

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        let centerRect = CGRect(x: ciImage.extent.midX - 5, y: ciImage.extent.midY - 5, width: 10, height: 10)

        let cropped = ciImage.cropped(to: centerRect)
        if let cgImage = context.createCGImage(cropped, from: cropped.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            if let color = uiImage.averageColor {
                DispatchQueue.main.async {
                    self.detectedColor = (
                        Int(color.redValue * 255),
                        Int(color.greenValue * 255),
                        Int(color.blueValue * 255)
                    )
                }
            }
        }
    }
}

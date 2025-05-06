import SwiftUI
import AVFoundation

struct CameraColorDetectorView: View {
    @StateObject private var viewModel = CameraViewModel()

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.session)
                .ignoresSafeArea()

            // Kotak deteksi di tengah layar
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: 10, height: 10)

            // RGB feedback
            VStack {
                Spacer()
                if let color = viewModel.detectedColor {
                    Text("R: \(color.r) G: \(color.g) B: \(color.b)")
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            viewModel.configure()
        }
    }
}

#Preview {
    CameraColorDetectorView()
}

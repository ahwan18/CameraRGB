import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Selamat datang di Color Detector")
                    .font(.title2)
                    .padding()

                NavigationLink(destination: CameraColorDetectorView()) {
                    Text("Buka Kamera")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Beranda")
        }
    }
}

#Preview {
    ContentView()
}

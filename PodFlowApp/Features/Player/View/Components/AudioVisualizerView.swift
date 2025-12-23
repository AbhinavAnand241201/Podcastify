import SwiftUI

struct AudioVisualizerView: View {
    var isPlaying: Bool
    @State private var barHeights: [CGFloat] = Array(repeating: 10, count: 20)
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<20, id: \.self) { index in
                Capsule()
                    .fill(LinearGradient(colors: [.purple, .blue], startPoint: .bottom, endPoint: .top))
                    .frame(width: 4, height: barHeights[index])
                    .animation(.easeInOut(duration: 0.2), value: barHeights[index])
            }
        }
        .frame(height: 50)
        // This timer simulates the audio data reading
        .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
            if isPlaying {
                randomizeBars()
            } else {
                flattenBars()
            }
        }
    }
    
    private func randomizeBars() {
        barHeights = (0..<20).map { _ in CGFloat.random(in: 10...50) }
    }
    
    private func flattenBars() {
        barHeights = Array(repeating: 4, count: 20)
    }
}
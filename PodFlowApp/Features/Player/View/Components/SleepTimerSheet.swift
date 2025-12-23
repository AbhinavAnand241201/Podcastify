import SwiftUI

struct SleepTimerSheet: View {
    @ObservedObject var audioService = AudioPlayerService.shared
    @Environment(\.dismiss) var dismiss
    
    let options: [Double] = [15, 30, 45, 60]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sleep Timer")
                .font(.headline)
                .padding(.top)
            
            Divider()
            
            ForEach(options, id: \.self) { minutes in
                Button(action: {
                    audioService.startSleepTimer(minutes: minutes)
                    dismiss()
                }) {
                    HStack {
                        Text("\(Int(minutes)) Minutes")
                            .foregroundColor(.primary)
                        Spacer()
                        if audioService.sleepTimerActive && audioService.sleepTimeRemaining == (minutes * 60) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            // Turn Off Button
            if audioService.sleepTimerActive {
                Button(action: {
                    audioService.cancelSleepTimer()
                    dismiss()
                }) {
                    Text("Turn Off Timer")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .presentationDetents([.medium])
    }
}
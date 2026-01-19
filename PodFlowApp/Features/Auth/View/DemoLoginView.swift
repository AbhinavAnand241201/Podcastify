import SwiftUI

struct DemoLoginView: View {
    @Binding var isAuthenticated: Bool
    @State private var isLoggingIn: Bool = false
    

    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Circle()
                .fill(brandColor)
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .opacity(0.3)
                .offset(y: -100)
            
            
            VStack(spacing: 40) {
                Spacer()
                
                VStack(spacing: 20) {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundStyle(brandColor)
                        .font(.system(size: 100))
                        .shadow(color: brandColor.opacity(0.5), radius: 20, x: 0, y: 0)
                    
                    Text("PodFlow")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Listen Better.")
                        .font(.title3)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                

                Button(action: performMockLogin) {
                    HStack(spacing: 12) {
                        if isLoggingIn {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text("G") 
                                .font(.title2.bold())
                                .foregroundStyle(
                                    AngularGradient(
                                        colors: [.red, .yellow, .green, .blue, .red],
                                        center: .center
                                    )
                                )
                            Text("Continue with Google")
                                .font(.headline)
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: isLoggingIn ? .clear : brandColor.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoggingIn)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }
    
    func performMockLogin() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation { isLoggingIn = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            UserDefaults.standard.set(UUID().uuidString, forKey: "userId")
            UserDefaults.standard.set("Demo User", forKey: "userName")
            UserDefaults.standard.set(true, forKey: "isAuthenticated")
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAuthenticated = true 
            }
        }
    }
}

#Preview {
    DemoLoginView(isAuthenticated: .constant(false))
}

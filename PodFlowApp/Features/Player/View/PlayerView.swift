import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel = PlayerViewModel.shared
    @ObservedObject var audioService = AudioPlayerService.shared
    

    

    @State private var showSleepTimer = false
    @State private var showBookmark = false
    
    var body: some View {
        if let episode = viewModel.currentEpisode, let podcast = viewModel.currentPodcast {
            VStack {
                if viewModel.isExpanded {
                    ExpandedPlayerView(episode: episode, podcast: podcast)
                } else {
                    MiniPlayerView(episode: episode, podcast: podcast)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: viewModel.isExpanded ? nil : 80)
            .background(
                viewModel.isExpanded
                ? Color.black
                : Color(uiColor: .secondarySystemBackground)
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    viewModel.isExpanded = true
                }
            }
            .gesture(
                DragGesture().onEnded { value in
                    if value.translation.height > 50 && viewModel.isExpanded {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            viewModel.isExpanded = false
                        }
                    }
                }
            )
        }
    }
    @ViewBuilder
    func MiniPlayerView(episode: Episode, podcast: Podcast) -> some View {
        HStack(spacing: 12) {
            AsyncImage(url: podcast.coverURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 45, height: 45)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .matchedGeometryEffect(id: "Artwork", in: animation)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(episode.title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "Title", in: animation)
                
                Text(podcast.title)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "8A2BE2"))
            }
            .padding(.trailing, 16)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    func ExpandedPlayerView(episode: Episode, podcast: Podcast) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 60)
                .padding(.bottom, 20)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 25) {
                    
                    AsyncImage(url: podcast.coverURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 300, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color(hex: "8A2BE2").opacity(0.4), radius: 30, x: 0, y: 10)
                    .matchedGeometryEffect(id: "Artwork", in: animation)
                    
                    if audioService.isPlaying {
                        AudioVisualizerView(isPlaying: audioService.isPlaying).frame(height: 30)
                    }
                    
                    VStack(spacing: 8) {
                        Text(episode.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                            .matchedGeometryEffect(id: "Title", in: animation)
                            .padding(.horizontal)
                        
                        Text(podcast.title)
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                    
                    VStack(spacing: 8) {
                        Slider(value: Binding(get: {
                            audioService.currentTime
                        }, set: { newValue in
                            viewModel.seek(to: newValue)
                        }), in: 0...audioService.duration)
                        .tint(Color(hex: "8A2BE2"))
                        
                        HStack {
                            Text(formatTime(audioService.currentTime))
                            Spacer()
                            Text(formatTime(audioService.duration))
                        }
                        .font(.caption)
                        .foregroundStyle(.gray)
                    }
                    .padding(.horizontal, 30)
                    
                    HStack(spacing: 40) {
                        Button { viewModel.seek(to: audioService.currentTime - 15) } label: {
                            Image(systemName: "gobackward.15").font(.largeTitle)
                        }
                        
                        Button { viewModel.togglePlayPause() } label: {
                            Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(Color(hex: "8A2BE2"))
                                .shadow(color: Color(hex: "8A2BE2").opacity(0.4), radius: 20)
                        }
                        
                        Button { viewModel.seek(to: audioService.currentTime + 30) } label: {
                            Image(systemName: "goforward.30").font(.largeTitle)
                        }
                    }
                    .foregroundStyle(.white)
                    
                    if viewModel.isAnalyzingAI {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(Color(hex: "8A2BE2"))
                            Text("AI is listening for highlights...")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding(.vertical, 10)
                    } else if !viewModel.aiChapters.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundStyle(Color(hex: "8A2BE2"))
                                Text("AI Highlights")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.aiChapters) { chapter in
                                        Button {
                                            withAnimation {
                                                viewModel.seek(to: chapter.time)
                                            }
                                        } label: {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Image(systemName: "clock.fill")
                                                        .font(.caption2)
                                                    Text(formatTime(chapter.time))
                                                        .font(.caption2)
                                                        .fontWeight(.bold)
                                                }
                                                .foregroundStyle(Color(hex: "8A2BE2"))
                                                
                                                Text(chapter.title)
                                                    .font(.caption)
                                                    .fontWeight(.bold)
                                                    .foregroundStyle(.white)
                                                
                                                Text("\"\(chapter.summary)...\"")
                                                    .font(.caption2)
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundStyle(.white.opacity(0.8))
                                            }
                                            .padding(12)
                                            .frame(width: 160, height: 100, alignment: .topLeading)
                                            .background(Color(hex: "1C1C1E"))
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    HStack(spacing: 50) {
                        Button {
                            let current = audioService.player?.rate ?? 1.0
                            let next = current >= 2.0 ? 1.0 : (current + 0.5)
                            audioService.setSpeed(next)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "speedometer")
                                Text("\(String(format: "%.1fx", audioService.player?.rate ?? 1.0))")
                                    .font(.caption2)
                            }
                        }
                        
                        Button { showSleepTimer.toggle() } label: {
                            VStack(spacing: 4) {
                                Image(systemName: audioService.sleepTimerActive ? "moon.stars.fill" : "moon.zzz")
                                    .foregroundStyle(audioService.sleepTimerActive ? Color(hex: "8A2BE2") : .white)
                                Text("Sleep")
                                    .font(.caption2)
                            }
                        }
                        
                        Button { showBookmark.toggle() } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "bookmark")
                                Text("Note")
                                    .font(.caption2)
                            }
                        }
                    }
                    .foregroundStyle(.gray)
                    .padding(.top, 10)
                    .padding(.bottom, 60)
                }
            }
        }
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
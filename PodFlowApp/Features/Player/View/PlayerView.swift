import SwiftUI

struct PlayerView: View {
    @ObservedObject var viewModel = PlayerViewModel.shared
    @ObservedObject var audioService = AudioPlayerService.shared
    
    @Namespace private var animation
    
    // NEW STATES for Sheets
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
            .background(
                viewModel.isExpanded
                ? AnyShapeStyle(Color(uiColor: .systemBackground))
                : AnyShapeStyle(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: viewModel.isExpanded ? 0 : 20))
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
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
            .ignoresSafeArea()
            // NEW: Sheets
            .sheet(isPresented: $showSleepTimer) {
                SleepTimerSheet()
            }
            .sheet(isPresented: $showBookmark) {
                BookmarkInputSheet(episodeID: episode.id, currentTimestamp: audioService.currentTime)
                    .presentationDetents([.height(300)])
            }
        }
    }
    
    // MARK: - MINI PLAYER COMPONENT
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
                    .lineLimit(1)
                    .matchedGeometryEffect(id: "Title", in: animation)
                
                Text(podcast.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: { viewModel.togglePlayPause() }) {
                Image(systemName: audioService.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            .padding(.trailing, 10)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .frame(height: 70)
        .padding(.bottom, 30)
    }
    
    // MARK: - EXPANDED PLAYER COMPONENT
    @ViewBuilder
    func ExpandedPlayerView(episode: Episode, podcast: Podcast) -> some View {
        VStack(spacing: 20) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 40)
            
            Spacer()
            
            // Big Artwork
            AsyncImage(url: podcast.coverURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray
            }
            .frame(width: 300, height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
            .matchedGeometryEffect(id: "Artwork", in: animation)
            
            // NEW: VISUALIZER (Only shows when playing)
            if audioService.isPlaying {
                AudioVisualizerView(isPlaying: audioService.isPlaying)
                    .transition(.opacity)
            }
            
            // Info
            VStack(spacing: 8) {
                Text(episode.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .matchedGeometryEffect(id: "Title", in: animation)
                
                Text(podcast.title)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            
            // Scrubber
            VStack(spacing: 5) {
                Slider(value: Binding(get: {
                    audioService.currentTime
                }, set: { newValue in
                    viewModel.seek(to: newValue)
                }), in: 0...audioService.duration)
                
                HStack {
                    Text(formatTime(audioService.currentTime))
                    Spacer()
                    Text(formatTime(audioService.duration))
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 30)
            
            // Controls
            HStack(spacing: 40) {
                Button { viewModel.seek(to: audioService.currentTime - 15) } label: {
                    Image(systemName: "gobackward.15").font(.largeTitle)
                }
                
                Button { viewModel.togglePlayPause() } label: {
                    Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.primary)
                }
                
                Button { viewModel.seek(to: audioService.currentTime + 30) } label: {
                    Image(systemName: "goforward.30").font(.largeTitle)
                }
            }
            .foregroundStyle(.primary)
            
            // NEW: Extra Tools Row (Speed, Sleep, Bookmark)
            HStack(spacing: 40) {
                // Speed Button
                Button {
                    let current = audioService.player?.rate ?? 1.0
                    let next = current >= 2.0 ? 1.0 : (current + 0.5)
                    audioService.setSpeed(next)
                } label: {
                    VStack {
                        Image(systemName: "speedometer")
                        Text("\(String(format: "%.1fx", audioService.player?.rate ?? 1.0))")
                            .font(.caption2)
                    }
                }
                
                // Sleep Timer Button
                Button {
                    showSleepTimer.toggle()
                } label: {
                    VStack {
                        Image(systemName: audioService.sleepTimerActive ? "moon.stars.fill" : "moon.zzz")
                            .foregroundStyle(audioService.sleepTimerActive ? .purple : .primary)
                        Text(audioService.sleepTimerActive ? "\(Int(audioService.sleepTimeRemaining/60))m" : "Sleep")
                            .font(.caption2)
                    }
                }
                
                // Bookmark Button
                Button {
                    showBookmark.toggle()
                } label: {
                    VStack {
                        Image(systemName: "bookmark")
                        Text("Note")
                            .font(.caption2)
                    }
                }
            }
            .padding(.top, 20)
            .foregroundStyle(.primary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
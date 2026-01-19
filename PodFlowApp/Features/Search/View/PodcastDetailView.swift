import SwiftUI
import SwiftData

struct PodcastDetailView: View {
    let podcast: Podcast
    @StateObject private var viewModel = PodcastDetailViewModel()
    @ObservedObject var downloadManager = DownloadManager.shared
    
    @Environment(\.modelContext) private var modelContext
    @Query private var savedPodcasts: [SavedPodcast]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Header Section
                VStack(spacing: 16) {
                    AsyncImage(url: podcast.coverURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 180, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .purple.opacity(0.4), radius: 20, x: 0, y: 10) // Purple Shadow Glow
                    
                    VStack(spacing: 8) {
                        Text(podcast.title)
                            .font(.title2)
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                        
                        Text(podcast.author)
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal)
                
                // MARK: - Subscribe Button
                Button(action: toggleSubscription) {
                    HStack {
                        Image(systemName: isSaved ? "checkmark" : "plus")
                        Text(isSaved ? "In Library" : "Subscribe")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(uiColor: .tertiarySystemBackground))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                }
                
                // MARK: - Episodes List
                VStack(alignment: .leading, spacing: 20) {
                    Text("Episodes")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView().tint(.purple).padding()
                    } else {
                        ForEach(viewModel.episodes) { episode in
                            HStack(alignment: .top, spacing: 16) {
                                // Info
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(episode.title)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    Text(episode.description)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                // MARK: - Action Buttons
                                HStack(spacing: 12) {
                                    // 1. NEON PURPLE PLAY BUTTON
                                    Button(action: {
                                        PlayerViewModel.shared.play(episode: episode, podcast: podcast)
                                    }) {
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 36))
                                            .foregroundStyle(Color.purple)
                                            .background(Circle().fill(Color.white).frame(width: 15, height: 15)) // White backing for contrast
                                    }
                                    .buttonStyle(.plain)
                                    
                                    // 2. SHINY DOWNLOAD BUTTON
                                    Button(action: {
                                        Task {
                                            if downloadManager.isDownloaded(episodeID: episode.id) {
                                                downloadManager.deleteEpisode(episodeID: episode.id)
                                            } else {
                                                try? await downloadManager.downloadEpisode(episode: episode)
                                            }
                                        }
                                    }) {
                                        if downloadManager.isDownloaded(episodeID: episode.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title2)
                                                .foregroundStyle(.green)
                                        } else {
                                            // Shiny Gradient Look
                                            Image(systemName: "arrow.down.circle.fill")
                                                .font(.title2)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.white, Color(uiColor: .lightGray)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .shadow(color: .white.opacity(0.3), radius: 4)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemBackground)) // Dark Card
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.bottom, 90) // Clear mini player
            }
            .padding(.top)
        }
        .background(Color.black.ignoresSafeArea()) // Global Black Background
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadEpisodes(feedUrl: podcast.feedUrl)
        }
    }
    
    var isSaved: Bool {
        savedPodcasts.contains { $0.id == podcast.collectionId }
    }
    
    private func toggleSubscription() {
        let id = podcast.collectionId
        if let index = savedPodcasts.firstIndex(where: { $0.id == id }) {
            modelContext.delete(savedPodcasts[index])
        } else {
            let newSave = SavedPodcast(
                id: podcast.collectionId,
                title: podcast.title,
                author: podcast.author,
                artworkURL: podcast.artworkUrl600 ?? "",
                feedURL: podcast.feedUrl ?? ""
            )
            modelContext.insert(newSave)
        }
    }
}
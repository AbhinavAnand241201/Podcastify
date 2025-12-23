import SwiftUI
import SwiftData

struct PodcastDetailView: View {
    let podcast: Podcast
    @StateObject private var viewModel = PodcastDetailViewModel()
    @ObservedObject var downloadManager = DownloadManager.shared // <--- NEW: Listen for download updates
    
    // SwiftData Context
    @Environment(\.modelContext) private var modelContext
    @Query private var savedPodcasts: [SavedPodcast]
    
    var body: some View {
        List {
            // Header Section
            VStack(spacing: 16) {
                AsyncImage(url: podcast.coverURL) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 150, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
                
                Text(podcast.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(podcast.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .listRowSeparator(.hidden)
            .padding(.bottom, 20)
            
            // Episodes List
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else {
                ForEach(viewModel.episodes) { episode in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(episode.title)
                            .font(.headline)
                            .lineLimit(2)
                        
                        Text(episode.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                        
                        // MARK: - CONTROLS ROW (Play + Download)
                        HStack {
                            // 1. PLAY BUTTON
                            Button(action: {
                                PlayerViewModel.shared.play(episode: episode, podcast: podcast)
                            }) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundStyle(.blue)
                                        .font(.title3)
                                    Text("Play")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.blue)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            // 2. DOWNLOAD BUTTON
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
                                    // Downloaded State
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text("Downloaded")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.green)
                                } else {
                                    // Not Downloaded State
                                    Image(systemName: "arrow.down.circle")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        // Toolbar: Subscribe Button
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: toggleSubscription) {
                    let isSaved = savedPodcasts.contains { $0.id == podcast.collectionId }
                    Image(systemName: isSaved ? "checkmark.circle.fill" : "plus.circle")
                        .font(.title3)
                        .foregroundStyle(isSaved ? .green : .primary)
                }
            }
        }
        .task {
            await viewModel.loadEpisodes(feedUrl: podcast.feedUrl)
        }
    }
    
    // Subscribe Logic
    private func toggleSubscription() {
        let id = podcast.collectionId
        
        if let savedIndex = savedPodcasts.firstIndex(where: { $0.id == id }) {
            modelContext.delete(savedPodcasts[savedIndex])
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
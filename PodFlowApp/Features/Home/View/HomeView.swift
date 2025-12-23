import SwiftUI
import SwiftData

struct HomeView: View {
    // 1. Get Favorites from Database
    @Query(sort: \SavedPodcast.dateAdded, order: .reverse) var favorites: [SavedPodcast]
    
    // 2. Get Downloads from Manager
    @ObservedObject var downloadManager = DownloadManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    
                    // SECTION 1: DOWNLOADED (OFFLINE READY)
                    // We filter episodes that are actually on disk
                    if !downloadManager.downloadedEpisodeIDs.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Ready to Play (Offline)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // In a real app, you'd fetch the full Episode objects from a DB.
                                    // For this MVP, we will show a placeholder or basic info if we had it saved.
                                    // To keep it simple and crash-free, we show a "Downloads" card that links to Library.
                                    
                                    NavigationLink(destination: LibraryView()) {
                                        VStack {
                                            Image(systemName: "arrow.down.circle.fill")
                                                .font(.system(size: 40))
                                                .foregroundStyle(.green)
                                                .frame(width: 140, height: 140)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(12)
                                            
                                            Text("See All Downloads")
                                                .font(.headline)
                                                .foregroundStyle(.primary)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    // SECTION 2: FAVORITES
                    if !favorites.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Your Favorites")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(favorites) { saved in
                                        NavigationLink(destination: PodcastDetailView(podcast: Podcast(
                                            collectionId: saved.id,
                                            collectionName: saved.title,
                                            artistName: saved.author,
                                            artworkUrl600: saved.artworkURL,
                                            feedUrl: saved.feedURL,
                                            primaryGenreName: nil,
                                            trackCount: nil
                                        ))) {
                                            VStack(alignment: .leading) {
                                                AsyncImage(url: URL(string: saved.artworkURL)) { image in
                                                    image.resizable().aspectRatio(contentMode: .fill)
                                                } placeholder: {
                                                    Color.gray
                                                }
                                                .frame(width: 140, height: 140)
                                                .cornerRadius(12)
                                                
                                                Text(saved.title)
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                    .frame(width: 140, alignment: .leading)
                                                    .foregroundStyle(.primary)
                                                
                                                Text(saved.author)
                                                    .font(.caption)
                                                    .lineLimit(1)
                                                    .frame(width: 140, alignment: .leading)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Empty State
                        ContentUnavailableView("Welcome to PodFlow", 
                                               systemImage: "waveform", 
                                               description: Text("Search for podcasts to build your home screen."))
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Home")
        }
    }
}
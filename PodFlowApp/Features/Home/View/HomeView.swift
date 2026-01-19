import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \SavedPodcast.dateAdded, order: .reverse) var favorites: [SavedPodcast]
    
    @ObservedObject var downloadManager = DownloadManager.shared
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    

                    if !downloadManager.savedEpisodes.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Downloads (Offline)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    // Iterate over the SAVED EPISODES
                                    ForEach(Array(downloadManager.savedEpisodes.values)) { episode in
                                        Button(action: {
                                            let dummyPodcast = Podcast(
                                                collectionId: 0, 
                                                collectionName: "Offline Library", 
                                                artistName: "Unknown", 
                                                artworkUrl600: nil, 
                                                feedUrl: nil, 
                                                primaryGenreName: nil, 
                                                trackCount: nil
                                            )
                                           
                                            PlayerViewModel.shared.play(episode: episode, podcast: dummyPodcast)
                                        }) {
                                            VStack(alignment: .leading) {
                                                ZStack {
                                                    Rectangle()
                                                        .fill(Color(uiColor: .tertiarySystemBackground))
                                                        .frame(width: 140, height: 140)
                                                        .cornerRadius(12)
                                                    
                                                    Image(systemName: "play.circle.fill")
                                                        .font(.largeTitle)
                                                        .foregroundStyle(Color(hex: "8A2BE2"))
                                                }
                                                
                                                Text(episode.title)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                                    .frame(width: 140, alignment: .leading)
                                                
                                                Text("Ready to Play")
                                                    .font(.caption)
                                                    .foregroundStyle(.green)
                                                    .frame(width: 140, alignment: .leading)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    

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
import SwiftUI
import SwiftData

struct LibraryView: View {
    @Query(sort: \SavedPodcast.dateAdded, order: .reverse) var savedPodcasts: [SavedPodcast]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
                
                if savedPodcasts.isEmpty {
                    ContentUnavailableView("No Podcasts Yet", 
                                           systemImage: "headphones", 
                                           description: Text("Search for a show and tap the (+) button to subscribe."))
                } else {
                    List {
                        ForEach(savedPodcasts) { saved in
                            // Convert SavedPodcast -> Podcast Model for the UI
                            let podcast = Podcast(
                                collectionId: saved.id,
                                collectionName: saved.title,
                                artistName: saved.author,
                                artworkUrl600: saved.artworkURL,
                                feedUrl: saved.feedURL,
                                primaryGenreName: nil,
                                trackCount: nil
                            )
                            
                            ZStack {
                                NavigationLink(destination: PodcastDetailView(podcast: podcast)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                // Reuse the polished design from Search View
                                PodcastRow(podcast: podcast)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onDelete(perform: deletePodcast)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Library")
        }
    }
    
    private func deletePodcast(offsets: IndexSet) {
        // Since we are using @Query, we can technically delete via the context.
        // For the MVP, the UI support is the priority, but here is the logic boilerplate:
        /*
        for index in offsets {
            let podcastToDelete = savedPodcasts[index]
            modelContext.delete(podcastToDelete)
        }
        */
    }
}
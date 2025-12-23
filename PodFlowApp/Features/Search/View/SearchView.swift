import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = "Tech" // Default search to show data immediately
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Searching...")
                        .controlSize(.large)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(error))
                } else {
                    List(viewModel.podcasts) { podcast in
    ZStack {
        // Empty Navigation Link prevents the arrow > from showing
        NavigationLink(destination: PodcastDetailView(podcast: podcast)) {
            EmptyView()
        }
        .opacity(0)
        
        PodcastRow(podcast: podcast)
    }
    .listRowSeparator(.hidden)
    .listRowBackground(Color.clear)
}
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, prompt: "Search Podcasts")
            .onChange(of: searchText) { oldValue, newValue in
                 // Debounce could be added here, but for now we search on submit or manually
            }
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchPodcasts(query: searchText)
                }
            }
            .task {
                // Initial load
                await viewModel.searchPodcasts(query: searchText)
            }
        }
    }
}

// A Sub-View for the List Row
struct PodcastRow: View {
    let podcast: Podcast
    
    var body: some View {
        HStack(spacing: 16) {
            // AsyncImage with caching logic is better, but this is standard for Phase 1
            AsyncImage(url: podcast.coverURL) { phase in
                switch phase {
                case .empty:
                    Rectangle().fill(Color.gray.opacity(0.3))
                case .success(let image):
                    image.resizable().aspectRatio(contentMode: .fill)
                case .failure:
                    Rectangle().fill(Color.gray.opacity(0.3))
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(podcast.title)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(podcast.author)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                if let genre = podcast.primaryGenreName {
                    Text(genre)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
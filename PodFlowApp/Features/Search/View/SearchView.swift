import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = "Tech"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. Force Pure Black Background
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.purple)
                        .scaleEffect(1.5)
                } else if let error = viewModel.errorMessage {
                    ContentUnavailableView("Oops", systemImage: "exclamationmark.triangle", description: Text(error))
                        .foregroundStyle(.white)
                } else {
                    // 2. Custom ScrollView instead of standard List for full design control
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.podcasts) { podcast in
                                NavigationLink(destination: PodcastDetailView(podcast: podcast)) {
                                    PodcastRow(podcast: podcast)
                                }
                                .buttonStyle(.plain) // Removes default blue link styling
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        // Add bottom padding so the last item clears the mini player
                        .padding(.bottom, 90) 
                    }
                }
            }
            .navigationTitle("Discover")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                Task { await viewModel.searchPodcasts(query: searchText) }
            }
            .task {
                await viewModel.searchPodcasts(query: searchText)
            }
        }
    }
}

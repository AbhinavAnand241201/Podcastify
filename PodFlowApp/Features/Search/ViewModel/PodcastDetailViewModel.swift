import Foundation

@MainActor
class PodcastDetailViewModel: ObservableObject {
    @Published var episodes: [Episode] = []
    @Published var isLoading = false
    
    func loadEpisodes(feedUrl: String?) async {
        guard let urlString = feedUrl, let url = URL(string: urlString) else { return }
        
        self.isLoading = true
        
        do {
            let parser = RSSFeedParser()
            let fetchedEpisodes = try await parser.parse(url: url)
            self.episodes = fetchedEpisodes
            self.isLoading = false
        } catch {
            print("Error parsing feed: \(error)")
            self.isLoading = false
        }
    }
}
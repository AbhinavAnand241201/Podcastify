import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    
    @Published var podcasts: [Podcast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let apiClient = APIClient.shared
    
    func searchPodcasts(query: String) async {
        // Guard against empty queries
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        self.isLoading = true
        self.errorMessage = nil
        
        // Encode the query (e.g., "lex fridman" -> "lex%20fridman")
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://itunes.apple.com/search?term=\(encodedQuery)&entity=podcast"
        
        do {
            // Tell the APIClient to expect an ITunesSearchResponse
            let response: ITunesSearchResponse = try await apiClient.fetch(urlString)
            self.podcasts = response.results
            self.isLoading = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.isLoading = false
        }
    }
}
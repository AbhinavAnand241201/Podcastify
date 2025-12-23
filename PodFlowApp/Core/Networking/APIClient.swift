import Foundation

actor APIClient {
    
    // Singleton instance for simplicity in this phase
    static let shared = APIClient()
    
    private init() {}
    
    /// Generic fetch method.
    /// - Parameters:
    ///   - urlString: The absolute URL string
    /// - Returns: The generic type T (e.g., ITunesSearchResponse)
    func fetch<T: Decodable>(_ urlString: String) async throws -> T {
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Use URLSession to fetch data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validate HTTP Response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw NetworkError.badServerResponse(code)
        }
        
        // Decode Data
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding Error: \(error)") // Debugging help
            throw NetworkError.decodingError
        }
    }
}
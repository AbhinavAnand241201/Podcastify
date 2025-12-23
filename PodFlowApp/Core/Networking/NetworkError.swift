import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case badServerResponse(Int) // Captures HTTP Status Code
    case decodingError
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided was invalid."
        case .badServerResponse(let code):
            return "Server returned an error. Status code: \(code)"
        case .decodingError:
            return "Failed to parse the data from the server."
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}
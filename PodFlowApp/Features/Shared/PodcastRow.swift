import SwiftUI

struct PodcastRow: View {
    let podcast: Podcast
    
    var body: some View {
        HStack(spacing: 16) {
            // 1. Artwork
            AsyncImage(url: podcast.coverURL) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    Rectangle().fill(Color.gray.opacity(0.2))
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            )
            
            // 2. Info (Left Aligned)
            VStack(alignment: .leading, spacing: 6) {
                Text(podcast.title)
                    .font(.headline)
                    .fontWeight(.bold) // Thicker font
                    .foregroundStyle(.white) // Pure White
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(podcast.author)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.gray) // Subtle Gray
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(uiColor: .tertiarySystemBackground)) // Dark Gray Card
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
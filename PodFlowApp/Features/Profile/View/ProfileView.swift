import SwiftUI
import Charts
import SwiftData

struct ProfileView: View {
    @Query var stats: [UserStats]
    
    var userStats: UserStats {
        if let existing = stats.first { return existing }
        return UserStats() // Placeholder until data is saved
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // 1. Header Stats
                    HStack(spacing: 20) {
                        StatCard(title: "Total Time", value: formatMinutes(userStats.totalMinutesListened), icon: "hourglass")
                        StatCard(title: "Top Genre", value: getTopGenre(), icon: "star.fill")
                    }
                    .padding(.horizontal)
                    
                    // 2. Genre Chart
                    VStack(alignment: .leading) {
                        Text("Listening Tastes")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Chart {
                            ForEach(userStats.genreCounts.sorted(by: { $0.value > $1.value }).prefix(5), id: \.key) { genre, count in
                                BarMark(
                                    x: .value("Count", count),
                                    y: .value("Genre", genre)
                                )
                                .foregroundStyle(Color.purple.gradient)
                            }
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Your Profile")
            .background(Color.black)
        }
    }
    
    // Helpers
    func getTopGenre() -> String {
        return userStats.genreCounts.max(by: { a, b in a.value < b.value })?.key ?? "None"
    }
    
    func formatMinutes(_ minutes: Double) -> String {
        if minutes < 60 { return "\(Int(minutes))m" }
        let hrs = Int(minutes / 60)
        return "\(hrs)h \(Int(minutes) % 60)m"
    }
}

// Subview for the Stat Cards
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.purple)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
    }
}
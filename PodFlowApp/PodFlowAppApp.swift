import SwiftUI
import SwiftData

@main
struct PodFlowAppApp: App {
    @ObservedObject var playerViewModel = PlayerViewModel.shared
    
    @AppStorage("isAuthenticated") var isAuthenticated = false
    
    init() {

        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor.black
        

        let neonPurple = UIColor(Color(hex: "8A2BE2"))
        tabAppearance.stackedLayoutAppearance.selected.iconColor = neonPurple
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: neonPurple]
        

        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.gray]
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ZStack(alignment: .bottom) {

                    TabView {
                        HomeView()
                            .tabItem { Label("Home", systemImage: "house.fill") }
                        
                        SearchView()
                            .tabItem { Label("Discover", systemImage: "magnifyingglass") }
                        
                        LibraryView()
                            .tabItem { Label("Library", systemImage: "books.vertical.fill") }
                        
                        ProfileView()
                            .tabItem { Label("Profile", systemImage: "chart.bar.xaxis") }
                    }
                    .accentColor(Color(hex: "8A2BE2"))
                    .preferredColorScheme(.dark)
                    .safeAreaInset(edge: .bottom) {
                        if playerViewModel.isMiniPlayerVisible {
                            Color.clear.frame(height: 80)
                        }
                    }
                    

                    if playerViewModel.isMiniPlayerVisible {
                        PlayerView()
                            .zIndex(1)
                    }
                }
                .modelContainer(for: [SavedPodcast.self, Bookmark.self, RecentlyPlayed.self, UserStats.self])
            } else {
                DemoLoginView(isAuthenticated: $isAuthenticated)
            }
        }
    }
}


extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
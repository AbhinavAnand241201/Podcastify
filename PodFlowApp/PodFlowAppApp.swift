import SwiftUI
import SwiftData

@main
struct PodFlowAppApp: App {
    @ObservedObject var playerViewModel = PlayerViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .bottom) {
                TabView {
                    // TAB 1: HOME
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                    
                    // TAB 2: SEARCH
                    SearchView()
                        .tabItem {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    
                    // TAB 3: LIBRARY
                    LibraryView()
                        .tabItem {
                            Label("Library", systemImage: "books.vertical.fill")
                        }
                }
                .padding(.bottom, playerViewModel.isMiniPlayerVisible ? 60 : 0)
                
                if playerViewModel.isMiniPlayerVisible {
                    PlayerView()
                        .transition(.move(edge: .bottom))
                        .zIndex(1)
                }
            }
            .modelContainer(for: [SavedPodcast.self, Bookmark.self, RecentlyPlayed.self])
        }
    }
}
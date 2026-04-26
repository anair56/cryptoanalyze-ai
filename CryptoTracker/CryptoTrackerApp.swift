import SwiftUI
import SwiftData

@main
struct CryptoTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PortfolioItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        NotificationService.shared.setupNotificationCategories()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    Task {
                        await NotificationService.shared.requestPermission()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CoinListView()
                .tabItem {
                    Label("Market", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(0)

            NewsListView()
                .tabItem {
                    Label("News", systemImage: "newspaper")
                }
                .tag(1)
                .badge(3)

            PortfolioView()
                .tabItem {
                    Label("Portfolio", systemImage: "briefcase")
                }
                .tag(2)
        }
    }
}
import Foundation
import UserNotifications

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    @Published var isEnabled = false
    private let center = UNUserNotificationCenter.current()

    private init() {
        checkNotificationStatus()
    }

    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run {
                self.isEnabled = granted
            }
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    func checkNotificationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isEnabled = settings.authorizationStatus == .authorized
            }
        }
    }

    func scheduleNewsNotification(for article: NewsArticle) {
        guard isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "📰 Crypto News Alert"
        content.subtitle = article.source.name
        content.body = article.title
        content.sound = .default

        if let sentiment = article.sentiment {
            content.categoryIdentifier = "NEWS_\(sentiment.label.rawValue.uppercased())"
            content.badge = sentiment.label == .veryBullish ? 1 : sentiment.label == .veryBearish ? -1 : 0
        }

        content.userInfo = [
            "articleId": article.id,
            "url": article.url,
            "coins": article.relevantCoins.joined(separator: ",")
        ]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "news_\(article.id)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }

    func schedulePortfolioImpactNotification(article: NewsArticle, impact: String, relevance: Double) {
        guard isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "💼 Portfolio Impact Alert"
        content.subtitle = "\(Int(relevance * 100))% Relevance to Your Holdings"
        content.body = "\(article.title)\n\nExpected Impact: \(impact)"
        content.sound = .default
        content.categoryIdentifier = "PORTFOLIO_IMPACT"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "portfolio_\(article.id)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling portfolio notification: \(error)")
            }
        }
    }

    func schedulePriceAlertNotification(coin: String, price: Double, threshold: Double, isAbove: Bool) {
        guard isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "💰 Price Alert"
        content.subtitle = "\(coin.uppercased()) Price \(isAbove ? "Above" : "Below") Threshold"
        content.body = "\(coin.capitalized) is now at $\(String(format: "%.2f", price)), \(isAbove ? "above" : "below") your threshold of $\(String(format: "%.2f", threshold))"
        content.sound = .default
        content.categoryIdentifier = "PRICE_ALERT"
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "price_\(coin)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Error scheduling price notification: \(error)")
            }
        }
    }

    func setupNotificationCategories() {
        let bullishAction = UNNotificationAction(
            identifier: "VIEW_DETAILS",
            title: "View Details",
            options: .foreground
        )

        let dismissAction = UNNotificationAction(
            identifier: "DISMISS",
            title: "Dismiss",
            options: .destructive
        )

        let portfolioAction = UNNotificationAction(
            identifier: "VIEW_PORTFOLIO",
            title: "View Portfolio",
            options: .foreground
        )

        let newsCategory = UNNotificationCategory(
            identifier: "NEWS_BULLISH",
            actions: [bullishAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let portfolioCategory = UNNotificationCategory(
            identifier: "PORTFOLIO_IMPACT",
            actions: [portfolioAction, bullishAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        let priceCategory = UNNotificationCategory(
            identifier: "PRICE_ALERT",
            actions: [bullishAction, dismissAction],
            intentIdentifiers: [],
            options: []
        )

        center.setNotificationCategories([newsCategory, portfolioCategory, priceCategory])
    }
}
import Foundation

struct NewsArticle: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let url: String
    let imageUrl: String?
    let publishedAt: Date
    let source: NewsSource
    let relevantCoins: [String]
    let sentiment: SentimentScore?
    let aiSummary: AISummary?

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
}

struct NewsSource: Codable {
    let name: String
    let domain: String?
}

struct SentimentScore: Codable {
    let score: Double
    let label: SentimentLabel

    enum SentimentLabel: String, Codable {
        case veryBearish = "very_bearish"
        case bearish = "bearish"
        case neutral = "neutral"
        case bullish = "bullish"
        case veryBullish = "very_bullish"

        var color: String {
            switch self {
            case .veryBearish: return "red"
            case .bearish: return "orange"
            case .neutral: return "gray"
            case .bullish: return "green"
            case .veryBullish: return "green"
            }
        }

        var emoji: String {
            switch self {
            case .veryBearish: return "📉"
            case .bearish: return "🐻"
            case .neutral: return "😐"
            case .bullish: return "🐂"
            case .veryBullish: return "🚀"
            }
        }
    }
}

struct AISummary: Codable {
    let summary: String
    let priceImpact: PriceImpact?
    let keyPoints: [String]
    let relevanceScore: Double
}

struct PriceImpact: Codable {
    let direction: Direction
    let magnitude: Magnitude
    let confidence: Double
    let affectedCoins: [String: ImpactDetail]

    enum Direction: String, Codable {
        case up = "up"
        case down = "down"
        case neutral = "neutral"
    }

    enum Magnitude: String, Codable {
        case high = "high"
        case medium = "medium"
        case low = "low"
    }
}

struct ImpactDetail: Codable {
    let coin: String
    let expectedChange: Double?
    let reasoning: String
}

struct NewsFilter {
    var searchText: String = ""
    var selectedCoins: Set<String> = []
    var sentimentFilter: SentimentScore.SentimentLabel?
    var dateRange: DateRange = .today
    var onlyPortfolioRelated: Bool = false

    enum DateRange: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
        case all = "All Time"

        var startDate: Date {
            let calendar = Calendar.current
            switch self {
            case .today:
                return calendar.startOfDay(for: Date())
            case .week:
                return calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            case .all:
                return Date.distantPast
            }
        }
    }
}

struct NewsResponse: Codable {
    let articles: [NewsArticle]
    let totalResults: Int
    let page: Int
    let hasMore: Bool
}
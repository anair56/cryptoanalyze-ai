import SwiftUI
import SwiftData

struct NewsListView: View {
    @StateObject private var newsService = NewsService.shared
    @State private var filter = NewsFilter()
    @State private var selectedArticle: NewsArticle?
    @State private var showFilterSheet = false
    @State private var isLoading = false
    @Query private var portfolioItems: [PortfolioItem]

    @ViewBuilder
    var mainContent: some View {
        VStack(spacing: 0) {
            filterBar

            if isLoading && newsService.articles.isEmpty {
                loadingView
            } else {
                newsListContent
            }
        }
    }

    var loadingView: some View {
        VStack {
            Spacer()
            ProgressView("Loading news...")
                .padding()
            Spacer()
        }
    }

    var newsListContent: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                if filteredArticles.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredArticles) { article in
                        NewsCardView(
                            article: article,
                            relevanceScore: calculateRelevance(for: article)
                        )
                        .onTapGesture {
                            selectedArticle = article
                        }
                    }
                }
            }
            .padding()
        }
        .refreshable {
            await loadNews()
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "newspaper")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No news found")
                .font(.headline)
            Text("Try adjusting your filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 50)
    }

    var body: some View {
        NavigationStack {
            mainContent
                .navigationTitle("Crypto News")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showFilterSheet.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                        }
                    }
                }
                .sheet(isPresented: $showFilterSheet) {
                    NewsFilterView(filter: $filter)
                }
                .sheet(item: $selectedArticle) { article in
                    NewsDetailView(article: article, portfolioItems: portfolioItems)
                }
                .task {
                    await loadNews()
                }
                .onChange(of: filter.dateRange) { _, _ in
                    Task {
                        await loadNews()
                    }
                }
                .onChange(of: filter.onlyPortfolioRelated) { _, _ in
                    Task {
                        await loadNews()
                    }
                }
                .onChange(of: filter.sentimentFilter) { _, _ in
                    Task {
                        await loadNews()
                    }
                }
                .onChange(of: filter.searchText) { _, _ in
                    Task {
                        await loadNews()
                    }
                }
        }
    }

    var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "Portfolio",
                    isSelected: filter.onlyPortfolioRelated
                ) {
                    filter.onlyPortfolioRelated.toggle()
                }

                ForEach(NewsFilter.DateRange.allCases, id: \.self) { range in
                    FilterChip(
                        title: range.rawValue,
                        isSelected: filter.dateRange == range
                    ) {
                        filter.dateRange = range
                    }
                }

                if let sentiment = filter.sentimentFilter {
                    FilterChip(
                        title: "\(sentiment.emoji) \(sentiment.rawValue.capitalized)",
                        isSelected: true
                    ) {
                        filter.sentimentFilter = nil
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(.systemGray6))
    }

    var filteredArticles: [NewsArticle] {
        newsService.articles.filter { article in
            if filter.onlyPortfolioRelated {
                let portfolioCoins = Set(portfolioItems.map { $0.coinId })
                let hasRelevantCoin = !Set(article.relevantCoins).intersection(portfolioCoins).isEmpty
                if !hasRelevantCoin { return false }
            }
            return true
        }
    }

    func calculateRelevance(for article: NewsArticle) -> Double {
        guard !portfolioItems.isEmpty else { return 0 }
        let portfolioCoins = Set(portfolioItems.map { $0.coinId })
        let relevantCoins = Set(article.relevantCoins).intersection(portfolioCoins)
        return Double(relevantCoins.count) / Double(portfolioCoins.count)
    }

    func loadNews() async {
        isLoading = true
        do {
            newsService.articles = try await newsService.fetchNews(filter: filter)
        } catch {
            print("Error loading news: \(error)")
        }
        isLoading = false
    }
}

struct NewsCardView: View {
    let article: NewsArticle
    let relevanceScore: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(article.source.name)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text(article.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        if let sentiment = article.sentiment {
                            SentimentBadge(sentiment: sentiment)
                        }
                    }

                    Text(article.title)
                        .font(.headline)
                        .lineLimit(2)

                    if let description = article.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    if let summary = article.aiSummary {
                        VStack(alignment: .leading, spacing: 6) {
                            Label("AI Summary", systemImage: "sparkles")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)

                            Text(summary.summary)
                                .font(.caption)
                                .lineLimit(3)
                                .foregroundColor(.primary.opacity(0.8))

                            if let impact = summary.priceImpact {
                                PriceImpactView(impact: impact)
                            }
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }

                    if !article.relevantCoins.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(article.relevantCoins.prefix(5), id: \.self) { coin in
                                    CoinChip(coinId: coin)
                                }
                            }
                        }
                    }

                    if relevanceScore > 0 {
                        HStack {
                            Image(systemName: "briefcase.fill")
                                .font(.caption)
                            Text("Portfolio Relevance: \(Int(relevanceScore * 100))%")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.green)
                    }
                }

                if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                    }
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct SentimentBadge: View {
    let sentiment: SentimentScore

    var body: some View {
        HStack(spacing: 4) {
            Text(sentiment.label.emoji)
                .font(.caption)
            Text(sentiment.label.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(sentiment.label.color).opacity(0.2))
        .foregroundColor(Color(sentiment.label.color))
        .cornerRadius(12)
    }
}

struct PriceImpactView: View {
    let impact: PriceImpact

    var iconName: String {
        switch impact.direction {
        case .up:
            return "arrow.up.circle.fill"
        case .down:
            return "arrow.down.circle.fill"
        default:
            return "minus.circle.fill"
        }
    }

    var iconColor: Color {
        switch impact.direction {
        case .up:
            return .green
        case .down:
            return .red
        default:
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)

            Text("Expected \(impact.magnitude.rawValue) impact")
                .font(.caption)
                .fontWeight(.medium)

            Text("(\(Int(impact.confidence * 100))% confidence)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CoinChip: View {
    let coinId: String

    var body: some View {
        Text(coinId.uppercased())
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.systemGray5))
            .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}
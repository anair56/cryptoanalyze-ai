import Foundation

class NewsService: ObservableObject {
    static let shared = NewsService()
    private let baseURL = "https://cryptopanic.com/api/v1"
    private let apiKey = "YOUR_CRYPTOPANIC_API_KEY"

    @Published var articles: [NewsArticle] = []
    @Published var isLoading = false
    @Published var error: String?

    private init() {}

    func fetchNews(filter: NewsFilter? = nil, page: Int = 1) async throws -> [NewsArticle] {
        var components = URLComponents(string: "\(baseURL)/posts/")
        components?.queryItems = [
            URLQueryItem(name: "auth_token", value: apiKey),
            URLQueryItem(name: "public", value: "true"),
            URLQueryItem(name: "page", value: String(page))
        ]

        if let filter = filter {
            if !filter.searchText.isEmpty {
                components?.queryItems?.append(URLQueryItem(name: "filter", value: filter.searchText))
            }
            if !filter.selectedCoins.isEmpty {
                let currencies = filter.selectedCoins.joined(separator: ",")
                components?.queryItems?.append(URLQueryItem(name: "currencies", value: currencies))
            }
        }

        return try await fetchMockNews(filter: filter)
    }

    private func fetchMockNews(filter: NewsFilter? = nil) async throws -> [NewsArticle] {
        try await Task.sleep(nanoseconds: 500_000_000)

        let mockArticles = [
            NewsArticle(
                id: "1",
                title: "Bitcoin Surges Past $50,000 as Institutional Adoption Accelerates",
                description: "Major corporations announce Bitcoin treasury allocations, driving price to new yearly highs.",
                url: "https://example.com/btc-surge",
                imageUrl: "https://images.unsplash.com/photo-1518546305927-5a555bb7020d",
                publishedAt: Date().addingTimeInterval(-3600),
                source: NewsSource(name: "CryptoNews", domain: "cryptonews.com"),
                relevantCoins: ["bitcoin", "ethereum"],
                sentiment: SentimentScore(score: 0.8, label: .bullish),
                aiSummary: AISummary(
                    summary: "Institutional adoption continues to drive Bitcoin's price momentum. Multiple Fortune 500 companies have announced BTC acquisitions for their treasuries, signaling growing confidence in crypto as a store of value.",
                    priceImpact: PriceImpact(
                        direction: .up,
                        magnitude: .high,
                        confidence: 0.75,
                        affectedCoins: [
                            "bitcoin": ImpactDetail(coin: "BTC", expectedChange: 5.5, reasoning: "Direct institutional buying pressure"),
                            "ethereum": ImpactDetail(coin: "ETH", expectedChange: 3.2, reasoning: "Correlation with BTC momentum")
                        ]
                    ),
                    keyPoints: [
                        "Three Fortune 500 companies announced BTC purchases",
                        "Combined allocation exceeds $2 billion",
                        "Analysts predict continued institutional interest"
                    ],
                    relevanceScore: 0.95
                )
            ),
            NewsArticle(
                id: "2",
                title: "Ethereum Layer 2 Solutions See Record Transaction Volume",
                description: "Arbitrum and Optimism process more transactions than Ethereum mainnet for the first time.",
                url: "https://example.com/eth-l2",
                imageUrl: "https://images.unsplash.com/photo-1639762681485-074b7f938ba0",
                publishedAt: Date().addingTimeInterval(-86400 * 2),
                source: NewsSource(name: "DeFi Daily", domain: "defidaily.com"),
                relevantCoins: ["ethereum", "arbitrum", "optimism"],
                sentiment: SentimentScore(score: 0.7, label: .bullish),
                aiSummary: AISummary(
                    summary: "Ethereum's Layer 2 scaling solutions have reached a major milestone with combined transaction volumes surpassing the mainnet. This indicates successful scaling adoption and reduced gas fees for users.",
                    priceImpact: PriceImpact(
                        direction: .up,
                        magnitude: .medium,
                        confidence: 0.65,
                        affectedCoins: [
                            "ethereum": ImpactDetail(coin: "ETH", expectedChange: 2.1, reasoning: "Increased utility and reduced congestion"),
                            "arbitrum": ImpactDetail(coin: "ARB", expectedChange: 8.3, reasoning: "Direct adoption metrics improvement")
                        ]
                    ),
                    keyPoints: [
                        "L2 transactions 40% cheaper than mainnet",
                        "DeFi TVL on L2s reaches $10 billion",
                        "Major DApps announcing L2 migrations"
                    ],
                    relevanceScore: 0.85
                )
            ),
            NewsArticle(
                id: "3",
                title: "SEC Delays Decision on Spot Bitcoin ETF Applications",
                description: "Regulatory uncertainty continues as the SEC postpones ruling on multiple Bitcoin ETF proposals.",
                url: "https://example.com/sec-delay",
                imageUrl: nil,
                publishedAt: Date().addingTimeInterval(-86400 * 5),
                source: NewsSource(name: "Regulatory Watch", domain: "regwatch.com"),
                relevantCoins: ["bitcoin"],
                sentiment: SentimentScore(score: 0.4, label: .bearish),
                aiSummary: AISummary(
                    summary: "The SEC has delayed its decision on pending spot Bitcoin ETF applications for another 60 days. While not a rejection, the continued delays create short-term uncertainty in the market.",
                    priceImpact: PriceImpact(
                        direction: .down,
                        magnitude: .low,
                        confidence: 0.6,
                        affectedCoins: [
                            "bitcoin": ImpactDetail(coin: "BTC", expectedChange: -1.5, reasoning: "Regulatory uncertainty typically causes minor selloffs")
                        ]
                    ),
                    keyPoints: [
                        "Decision postponed for 60 days",
                        "Market has largely priced in delays",
                        "Long-term approval still expected by analysts"
                    ],
                    relevanceScore: 0.75
                )
            ),
            NewsArticle(
                id: "4",
                title: "Solana Network Achieves 65,000 TPS in Latest Stress Test",
                description: "Solana demonstrates significant performance improvements following recent network upgrades.",
                url: "https://example.com/solana-tps",
                imageUrl: "https://images.unsplash.com/photo-1639762681485-074b7f938ba0",
                publishedAt: Date().addingTimeInterval(-86400 * 10),
                source: NewsSource(name: "Blockchain Tech", domain: "blockchaintech.io"),
                relevantCoins: ["solana"],
                sentiment: SentimentScore(score: 0.65, label: .bullish),
                aiSummary: AISummary(
                    summary: "Solana's latest network upgrades have resulted in record-breaking transaction speeds. The successful stress test demonstrates improved stability and scalability, addressing previous reliability concerns.",
                    priceImpact: PriceImpact(
                        direction: .up,
                        magnitude: .medium,
                        confidence: 0.7,
                        affectedCoins: [
                            "solana": ImpactDetail(coin: "SOL", expectedChange: 4.2, reasoning: "Technical improvements boost confidence")
                        ]
                    ),
                    keyPoints: [
                        "Network uptime at 99.9% for past 30 days",
                        "Transaction fees remain under $0.001",
                        "Developer activity increasing 25% month-over-month"
                    ],
                    relevanceScore: 0.8
                )
            ),
            NewsArticle(
                id: "5",
                title: "DeFi Protocol Hack Results in $30 Million Loss",
                description: "Another DeFi protocol falls victim to smart contract exploit, raising security concerns.",
                url: "https://example.com/defi-hack",
                imageUrl: nil,
                publishedAt: Date().addingTimeInterval(-86400 * 15),
                source: NewsSource(name: "Security Alert", domain: "secalert.com"),
                relevantCoins: ["ethereum", "chainlink"],
                sentiment: SentimentScore(score: 0.2, label: .veryBearish),
                aiSummary: AISummary(
                    summary: "A major DeFi protocol on Ethereum has been exploited for $30 million due to a smart contract vulnerability. This highlights ongoing security challenges in the DeFi ecosystem despite audit improvements.",
                    priceImpact: PriceImpact(
                        direction: .down,
                        magnitude: .low,
                        confidence: 0.55,
                        affectedCoins: [
                            "ethereum": ImpactDetail(coin: "ETH", expectedChange: -0.8, reasoning: "Minor impact due to ecosystem size"),
                            "defi-tokens": ImpactDetail(coin: "DeFi", expectedChange: -2.5, reasoning: "Sector-wide confidence impact")
                        ]
                    ),
                    keyPoints: [
                        "Exploit used flash loan attack vector",
                        "Team working on recovery plan",
                        "Calls for improved audit standards"
                    ],
                    relevanceScore: 0.6
                )
            ),
            NewsArticle(
                id: "6",
                title: "Ripple Wins Partial Victory in SEC Lawsuit",
                description: "Court rules XRP is not a security when sold to retail investors on exchanges.",
                url: "https://example.com/xrp-sec",
                imageUrl: "https://images.unsplash.com/photo-1621504450398-62c8e1ac6d57",
                publishedAt: Date().addingTimeInterval(-3600 * 2),
                source: NewsSource(name: "Legal News", domain: "legalnews.com"),
                relevantCoins: ["ripple", "xrp"],
                sentiment: SentimentScore(score: 0.75, label: .bullish),
                aiSummary: nil
            ),
            NewsArticle(
                id: "7",
                title: "Cardano Smart Contract Activity Reaches All-Time High",
                description: "DeFi ecosystem on Cardano shows significant growth with TVL surpassing $500 million.",
                url: "https://example.com/cardano-growth",
                imageUrl: nil,
                publishedAt: Date().addingTimeInterval(-86400 * 3),
                source: NewsSource(name: "Cardano Daily", domain: "cardanodaily.com"),
                relevantCoins: ["cardano", "ada"],
                sentiment: SentimentScore(score: 0.65, label: .bullish),
                aiSummary: nil
            ),
            NewsArticle(
                id: "8",
                title: "Polygon Partners with Major Gaming Studio for NFT Integration",
                description: "AAA gaming studio announces blockchain integration using Polygon for in-game assets.",
                url: "https://example.com/polygon-gaming",
                imageUrl: "https://images.unsplash.com/photo-1614680376573-c3e0f0dff7f1",
                publishedAt: Date().addingTimeInterval(-86400 * 8),
                source: NewsSource(name: "GameFi News", domain: "gamefi.news"),
                relevantCoins: ["polygon", "matic"],
                sentiment: SentimentScore(score: 0.6, label: .bullish),
                aiSummary: nil
            ),
            NewsArticle(
                id: "9",
                title: "Chainlink Introduces Cross-Chain Interoperability Protocol",
                description: "CCIP mainnet launch enables secure cross-chain messaging and token transfers.",
                url: "https://example.com/chainlink-ccip",
                imageUrl: nil,
                publishedAt: Date().addingTimeInterval(-86400 * 20),
                source: NewsSource(name: "Oracle Times", domain: "oracletimes.com"),
                relevantCoins: ["chainlink", "link"],
                sentiment: SentimentScore(score: 0.7, label: .bullish),
                aiSummary: nil
            ),
            NewsArticle(
                id: "10",
                title: "Binance Faces Regulatory Scrutiny in Multiple Countries",
                description: "Exchange announces withdrawal from several markets amid regulatory pressure.",
                url: "https://example.com/binance-regulation",
                imageUrl: nil,
                publishedAt: Date().addingTimeInterval(-86400 * 35),
                source: NewsSource(name: "Exchange Watch", domain: "exchangewatch.com"),
                relevantCoins: ["binancecoin", "bnb"],
                sentiment: SentimentScore(score: 0.3, label: .bearish),
                aiSummary: nil
            )
        ]

        var filtered = mockArticles

        if let filter = filter {
            if !filter.searchText.isEmpty {
                filtered = filtered.filter { article in
                    article.title.localizedCaseInsensitiveContains(filter.searchText) ||
                    (article.description?.localizedCaseInsensitiveContains(filter.searchText) ?? false)
                }
            }

            if let sentiment = filter.sentimentFilter {
                filtered = filtered.filter { $0.sentiment?.label == sentiment }
            }

            filtered = filtered.filter { article in
                article.publishedAt >= filter.dateRange.startDate
            }

            if !filter.selectedCoins.isEmpty {
                filtered = filtered.filter { article in
                    !Set(article.relevantCoins).intersection(filter.selectedCoins).isEmpty
                }
            }
        }

        return filtered
    }

    func generateAISummary(for article: NewsArticle, portfolio: [PortfolioItem]) async -> AISummary {
        let relevanceScore = calculateRelevanceScore(article: article, portfolio: portfolio)

        return AISummary(
            summary: "AI-generated summary based on article content and market context.",
            priceImpact: estimatePriceImpact(article: article),
            keyPoints: extractKeyPoints(from: article),
            relevanceScore: relevanceScore
        )
    }

    private func calculateRelevanceScore(article: NewsArticle, portfolio: [PortfolioItem]) -> Double {
        guard !portfolio.isEmpty else { return 0.5 }

        let portfolioCoins = Set(portfolio.map { $0.coinId })
        let articleCoins = Set(article.relevantCoins)
        let intersection = portfolioCoins.intersection(articleCoins)

        if intersection.isEmpty {
            return 0.2
        }

        let portfolioValue = portfolio.reduce(0) { $0 + $1.totalCost }
        let relevantValue = portfolio
            .filter { intersection.contains($0.coinId) }
            .reduce(0) { $0 + $1.totalCost }

        return min(1.0, (relevantValue / portfolioValue) * 1.5)
    }

    private func estimatePriceImpact(article: NewsArticle) -> PriceImpact {
        let sentiment = article.sentiment?.score ?? 0.5

        let direction: PriceImpact.Direction = sentiment > 0.6 ? .up : sentiment < 0.4 ? .down : .neutral
        let magnitude: PriceImpact.Magnitude = abs(sentiment - 0.5) > 0.3 ? .high : abs(sentiment - 0.5) > 0.15 ? .medium : .low

        return PriceImpact(
            direction: direction,
            magnitude: magnitude,
            confidence: min(0.9, abs(sentiment - 0.5) * 2),
            affectedCoins: [:]
        )
    }

    private func extractKeyPoints(from article: NewsArticle) -> [String] {
        return [
            "Key insight from article analysis",
            "Market impact assessment",
            "Relevant technical indicators"
        ]
    }
}
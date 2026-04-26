import SwiftUI

struct NewsDetailView: View {
    let article: NewsArticle
    let portfolioItems: [PortfolioItem]
    @Environment(\.dismiss) private var dismiss
    @State private var showFullSummary = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection

                    if let imageUrl = article.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                        }
                        .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(article.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            Label(article.source.name, systemImage: "newspaper")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Spacer()

                            Label(article.timeAgo, systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let description = article.description {
                        Text(description)
                            .font(.body)
                    }

                    aiSummarySection

                    priceImpactSection

                    relevantCoinsSection

                    portfolioRelevanceSection

                    Spacer(minLength: 20)

                    Button {
                        if let url = URL(string: article.url) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack {
                            Text("Read Full Article")
                            Image(systemName: "arrow.up.right.square")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    var headerSection: some View {
        HStack {
            if let sentiment = article.sentiment {
                SentimentBadge(sentiment: sentiment)
            }

            Spacer()

            ShareLink(item: URL(string: article.url)!) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.blue)
            }
        }
    }

    @ViewBuilder
    var aiSummarySection: some View {
        if let summary = article.aiSummary {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("AI Analysis", systemImage: "sparkles")
                        .font(.headline)
                        .foregroundColor(.blue)

                    Spacer()

                    if summary.relevanceScore > 0.7 {
                        Label("High Relevance", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Text(showFullSummary ? summary.summary : String(summary.summary.prefix(150)) + "...")
                    .font(.body)
                    .animation(.easeInOut, value: showFullSummary)

                if summary.summary.count > 150 {
                    Button {
                        showFullSummary.toggle()
                    } label: {
                        Text(showFullSummary ? "Show Less" : "Show More")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }

                if !summary.keyPoints.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Points")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(summary.keyPoints, id: \.self) { point in
                            HStack(alignment: .top) {
                                Text("•")
                                    .foregroundColor(.blue)
                                Text(point)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    var priceImpactSection: some View {
        if let impact = article.aiSummary?.priceImpact {
            VStack(alignment: .leading, spacing: 12) {
                Label("Expected Price Impact", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Direction")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: impact.direction == .up ? "arrow.up" : impact.direction == .down ? "arrow.down" : "minus")
                                .foregroundColor(impact.direction == .up ? .green : impact.direction == .down ? .red : .gray)
                            Text(impact.direction.rawValue.capitalized)
                                .fontWeight(.medium)
                        }
                    }

                    Spacer()

                    VStack(alignment: .center) {
                        Text("Magnitude")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(impact.magnitude.rawValue.capitalized)
                            .fontWeight(.medium)
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        Text("Confidence")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(impact.confidence * 100))%")
                            .fontWeight(.medium)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

                if !impact.affectedCoins.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Affected Coins")
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        ForEach(Array(impact.affectedCoins.keys), id: \.self) { coinKey in
                            if let detail = impact.affectedCoins[coinKey] {
                                HStack {
                                    Text(detail.coin)
                                        .font(.subheadline)
                                        .fontWeight(.medium)

                                    if let change = detail.expectedChange {
                                        Text("\(change > 0 ? "+" : "")\(change, specifier: "%.1f")%")
                                            .font(.caption)
                                            .foregroundColor(change > 0 ? .green : .red)
                                    }

                                    Spacer()

                                    Text(detail.reasoning)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.5))
            .cornerRadius(12)
        }
    }

    @ViewBuilder
    var relevantCoinsSection: some View {
        if !article.relevantCoins.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Label("Related Cryptocurrencies", systemImage: "link")
                    .font(.headline)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(article.relevantCoins, id: \.self) { coin in
                            HStack {
                                Image(systemName: "bitcoinsign.circle.fill")
                                    .foregroundColor(.orange)
                                Text(coin.uppercased())
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray5))
                            .cornerRadius(20)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    var portfolioRelevanceSection: some View {
        if !portfolioItems.isEmpty {
            let relevantItems = portfolioItems.filter { item in
                article.relevantCoins.contains(item.coinId)
            }

            if !relevantItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Impact on Your Portfolio", systemImage: "briefcase.fill")
                        .font(.headline)
                        .foregroundColor(.green)

                    ForEach(relevantItems, id: \.coinId) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.coinSymbol.uppercased())
                                    .fontWeight(.semibold)
                                Text("\(item.quantity, specifier: "%.4f") units")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if let impact = article.aiSummary?.priceImpact,
                               let detail = impact.affectedCoins[item.coinId],
                               let change = detail.expectedChange {
                                VStack(alignment: .trailing) {
                                    Text("Expected Impact")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(change > 0 ? "+" : "")\(change, specifier: "%.1f")%")
                                        .fontWeight(.medium)
                                        .foregroundColor(change > 0 ? .green : .red)
                                }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
            }
        }
    }
}
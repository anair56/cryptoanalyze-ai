import SwiftUI

struct NewsFilterView: View {
    @Binding var filter: NewsFilter
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    let sentimentOptions: [SentimentScore.SentimentLabel] = [
        .veryBullish, .bullish, .neutral, .bearish, .veryBearish
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Search") {
                    TextField("Search news...", text: $filter.searchText)
                }

                Section("Sentiment") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(sentimentOptions, id: \.self) { sentiment in
                                SentimentFilterButton(
                                    sentiment: sentiment,
                                    isSelected: filter.sentimentFilter == sentiment
                                ) {
                                    if filter.sentimentFilter == sentiment {
                                        filter.sentimentFilter = nil
                                    } else {
                                        filter.sentimentFilter = sentiment
                                    }
                                }
                            }
                        }
                    }
                }

                Section("Time Range") {
                    Picker("Date Range", selection: $filter.dateRange) {
                        ForEach(NewsFilter.DateRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Portfolio") {
                    Toggle("Show only portfolio-related news", isOn: $filter.onlyPortfolioRelated)
                }

                Section("Cryptocurrencies") {
                    Text("Filter by specific coins")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            CoinFilterChip(coin: "bitcoin", isSelected: filter.selectedCoins.contains("bitcoin")) {
                                toggleCoin("bitcoin")
                            }
                            CoinFilterChip(coin: "ethereum", isSelected: filter.selectedCoins.contains("ethereum")) {
                                toggleCoin("ethereum")
                            }
                            CoinFilterChip(coin: "solana", isSelected: filter.selectedCoins.contains("solana")) {
                                toggleCoin("solana")
                            }
                            CoinFilterChip(coin: "cardano", isSelected: filter.selectedCoins.contains("cardano")) {
                                toggleCoin("cardano")
                            }
                            CoinFilterChip(coin: "polkadot", isSelected: filter.selectedCoins.contains("polkadot")) {
                                toggleCoin("polkadot")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Filter News")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        filter = NewsFilter()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    func toggleCoin(_ coin: String) {
        if filter.selectedCoins.contains(coin) {
            filter.selectedCoins.remove(coin)
        } else {
            filter.selectedCoins.insert(coin)
        }
    }
}

struct SentimentFilterButton: View {
    let sentiment: SentimentScore.SentimentLabel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(sentiment.emoji)
                    .font(.title2)
                Text(sentiment.rawValue.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color(sentiment.color).opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? Color(sentiment.color) : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(sentiment.color) : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct CoinFilterChip: View {
    let coin: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundColor(.orange)
                Text(coin.capitalized)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}
import SwiftUI
import SwiftData

struct PortfolioView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \PortfolioItem.dateAdded, order: .reverse) private var portfolioItems: [PortfolioItem]
    @StateObject private var viewModel = PortfolioViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    portfolioSummaryCard

                    if portfolioItems.isEmpty {
                        emptyPortfolioView
                    } else {
                        portfolioItemsList
                    }
                }
                .padding()
            }
            .navigationTitle("Portfolio")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await viewModel.updatePortfolioValues(for: portfolioItems)
        }
    }

    var portfolioSummaryCard: some View {
        VStack(spacing: 15) {
            Text("Total Portfolio Value")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("$\(viewModel.totalValue, specifier: "%.2f")")
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("Total Cost")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(viewModel.totalCost, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }

                VStack(spacing: 4) {
                    Text("Total P/L")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(viewModel.totalProfitLoss, specifier: "%.2f")")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.totalProfitLoss >= 0 ? .green : .red)
                }

                VStack(spacing: 4) {
                    Text("P/L %")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.totalProfitLossPercentage, specifier: "%.2f")%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.totalProfitLossPercentage >= 0 ? .green : .red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    var emptyPortfolioView: some View {
        VStack(spacing: 20) {
            Image(systemName: "briefcase")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Your portfolio is empty")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start by adding cryptocurrencies to track your investments")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 50)
    }

    var portfolioItemsList: some View {
        VStack(spacing: 12) {
            ForEach(portfolioItems) { item in
                PortfolioItemCard(
                    item: item,
                    currentPrice: viewModel.currentPrices[item.coinId] ?? 0
                )
                .contextMenu {
                    Button(role: .destructive) {
                        deleteItem(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }

    func deleteItem(_ item: PortfolioItem) {
        withAnimation {
            modelContext.delete(item)
        }
    }
}

struct PortfolioItemCard: View {
    let item: PortfolioItem
    let currentPrice: Double

    var profitLoss: Double {
        item.profitLoss(at: currentPrice)
    }

    var profitLossPercentage: Double {
        item.profitLossPercentage(at: currentPrice)
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.coinSymbol.uppercased())
                        .font(.headline)
                    Text(item.coinName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(item.currentValue(at: currentPrice), specifier: "%.2f")")
                        .font(.headline)
                    HStack(spacing: 4) {
                        Text("\(profitLoss >= 0 ? "+" : "")$\(profitLoss, specifier: "%.2f")")
                        Text("(\(profitLossPercentage, specifier: "%.2f")%)")
                    }
                    .font(.caption)
                    .foregroundColor(profitLoss >= 0 ? .green : .red)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(item.quantity, specifier: "%.4f")")
                        .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Avg. Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(item.averagePurchasePrice, specifier: "%.2f")")
                        .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Current Price")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("$\(currentPrice, specifier: "%.2f")")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

@MainActor
class PortfolioViewModel: ObservableObject {
    @Published var currentPrices: [String: Double] = [:]
    @Published var totalValue: Double = 0
    @Published var totalCost: Double = 0
    @Published var totalProfitLoss: Double = 0
    @Published var totalProfitLossPercentage: Double = 0

    private let service = CoinGeckoService.shared

    func updatePortfolioValues(for items: [PortfolioItem]) async {
        let coinIds = items.map { $0.coinId }
        guard !coinIds.isEmpty else { return }

        do {
            let coins = try await service.fetchCoins(perPage: 250)
            let relevantCoins = coins.filter { coinIds.contains($0.id) }

            var prices: [String: Double] = [:]
            for coin in relevantCoins {
                prices[coin.id] = coin.currentPrice
            }
            currentPrices = prices

            calculateTotals(for: items)
        } catch {
            print("Error fetching current prices: \(error)")
        }
    }

    private func calculateTotals(for items: [PortfolioItem]) {
        var value = 0.0
        var cost = 0.0

        for item in items {
            let currentPrice = currentPrices[item.coinId] ?? 0
            value += item.currentValue(at: currentPrice)
            cost += item.totalCost
        }

        totalValue = value
        totalCost = cost
        totalProfitLoss = value - cost
        totalProfitLossPercentage = cost > 0 ? ((value - cost) / cost) * 100 : 0
    }
}
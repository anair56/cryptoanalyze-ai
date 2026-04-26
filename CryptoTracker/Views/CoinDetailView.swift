import SwiftUI

struct CoinDetailView: View {
    let coin: Coin
    @StateObject private var viewModel = CoinDetailViewModel()
    @State private var selectedTimeframe = 7
    @State private var showAddToPortfolio = false

    let timeframes = [
        (1, "24H"),
        (7, "7D"),
        (30, "30D"),
        (365, "1Y")
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                priceSection

                chartSection

                statisticsSection

                if let detail = viewModel.coinDetail {
                    descriptionSection(detail: detail)
                }
            }
            .padding()
        }
        .navigationTitle(coin.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddToPortfolio.toggle()
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .sheet(isPresented: $showAddToPortfolio) {
            AddToPortfolioView(coin: coin)
        }
        .task {
            await viewModel.loadCoinDetail(id: coin.id)
            await viewModel.loadMarketChart(id: coin.id, days: selectedTimeframe)
        }
    }

    var headerSection: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: coin.image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Circle()
                    .foregroundColor(.gray.opacity(0.3))
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(coin.symbol.uppercased())
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Rank #\(coin.marketCapRank)")
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }

    var priceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(coin.formattedPrice)
                .font(.largeTitle)
                .fontWeight(.bold)

            HStack(spacing: 10) {
                Label {
                    Text("\(abs(coin.priceChangePercentage24H ?? 0), specifier: "%.2f")%")
                } icon: {
                    Image(systemName: (coin.priceChangePercentage24H ?? 0) >= 0 ? "arrow.up" : "arrow.down")
                }
                .foregroundColor((coin.priceChangePercentage24H ?? 0) >= 0 ? .green : .red)

                Text("24h")
                    .foregroundColor(.secondary)
            }
        }
    }

    var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Price Chart")
                .font(.headline)

            Picker("Timeframe", selection: $selectedTimeframe) {
                ForEach(timeframes, id: \.0) { days, label in
                    Text(label).tag(days)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: selectedTimeframe) { _, newValue in
                Task {
                    await viewModel.loadMarketChart(id: coin.id, days: newValue)
                }
            }

            if viewModel.isLoadingChart {
                ProgressView()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            } else if let chartData = viewModel.marketChart?.priceData {
                SimplePriceChartView(data: chartData, color: (coin.priceChangePercentage24H ?? 0) >= 0 ? .green : .red)
                    .frame(height: 200)
            }
        }
    }

    var dateFormat: Date.FormatStyle {
        switch selectedTimeframe {
        case 1:
            return .dateTime.hour()
        case 7:
            return .dateTime.day().month(.abbreviated)
        case 30:
            return .dateTime.day().month(.abbreviated)
        default:
            return .dateTime.month().year()
        }
    }

    var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                StatisticView(title: "Market Cap", value: "$\(formatLargeNumber(coin.marketCap))")
                StatisticView(title: "24h Volume", value: "$\(formatLargeNumber(coin.totalVolume))")
                StatisticView(title: "24h High", value: coin.high24H != nil ? String(format: "$%.2f", coin.high24H!) : "N/A")
                StatisticView(title: "24h Low", value: coin.low24H != nil ? String(format: "$%.2f", coin.low24H!) : "N/A")
                StatisticView(title: "Circulating Supply", value: formatLargeNumber(coin.circulatingSupply))
                StatisticView(title: "Max Supply", value: coin.maxSupply != nil ? formatLargeNumber(coin.maxSupply!) : "N/A")
            }
        }
    }

    func descriptionSection(detail: CoinDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About")
                .font(.headline)

            Text(detail.description.en
                .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(viewModel.showFullDescription ? nil : 5)

            if detail.description.en.count > 200 {
                Button {
                    withAnimation {
                        viewModel.showFullDescription.toggle()
                    }
                } label: {
                    Text(viewModel.showFullDescription ? "Show Less" : "Show More")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
        }
    }

    func formatLargeNumber(_ number: Double) -> String {
        let billion = 1_000_000_000.0
        let million = 1_000_000.0
        let thousand = 1_000.0

        if number >= billion {
            return String(format: "%.2fB", number / billion)
        } else if number >= million {
            return String(format: "%.2fM", number / million)
        } else if number >= thousand {
            return String(format: "%.2fK", number / thousand)
        } else {
            return String(format: "%.0f", number)
        }
    }
}

struct StatisticView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

@MainActor
class CoinDetailViewModel: ObservableObject {
    @Published var coinDetail: CoinDetail?
    @Published var marketChart: MarketChart?
    @Published var isLoadingChart = false
    @Published var showFullDescription = false

    private let service = CoinGeckoService.shared

    func loadCoinDetail(id: String) async {
        do {
            let detail = try await service.fetchCoinDetail(id: id)
            coinDetail = detail
        } catch {
            print("Error loading coin detail: \(error)")
        }
    }

    func loadMarketChart(id: String, days: Int) async {
        isLoadingChart = true
        do {
            let chart = try await service.fetchMarketChart(id: id, days: days)
            marketChart = chart
        } catch {
            print("Error loading market chart: \(error)")
        }
        isLoadingChart = false
    }
}

struct SimplePriceChartView: View {
    let data: [ChartData]
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            if !data.isEmpty {
                let minPrice = data.map { $0.value }.min() ?? 0
                let maxPrice = data.map { $0.value }.max() ?? 1
                let priceRange = maxPrice - minPrice

                ZStack {
                    Path { path in
                        for (index, point) in data.enumerated() {
                            let xPosition = (CGFloat(index) / CGFloat(data.count - 1)) * geometry.size.width
                            let yPosition = (1 - (point.value - minPrice) / priceRange) * geometry.size.height

                            if index == 0 {
                                path.move(to: CGPoint(x: xPosition, y: yPosition))
                            } else {
                                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                            }
                        }
                    }
                    .stroke(color, lineWidth: 2)

                    Path { path in
                        for (index, point) in data.enumerated() {
                            let xPosition = (CGFloat(index) / CGFloat(data.count - 1)) * geometry.size.width
                            let yPosition = (1 - (point.value - minPrice) / priceRange) * geometry.size.height

                            if index == 0 {
                                path.move(to: CGPoint(x: xPosition, y: yPosition))
                            } else {
                                path.addLine(to: CGPoint(x: xPosition, y: yPosition))
                            }
                        }

                        if let lastPoint = data.last {
                            let lastX = geometry.size.width
                            let lastY = (1 - (lastPoint.value - minPrice) / priceRange) * geometry.size.height
                            path.addLine(to: CGPoint(x: lastX, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                            path.closeSubpath()
                        }
                    }
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.3), color.opacity(0)]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                }
            } else {
                Text("No data available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
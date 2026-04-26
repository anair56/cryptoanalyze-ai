import SwiftUI

struct CoinListView: View {
    @StateObject private var viewModel = CoinListViewModel()
    @State private var searchText = ""
    @State private var showingPortfolio = false

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && viewModel.coins.isEmpty {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(filteredCoins) { coin in
                        NavigationLink(destination: CoinDetailView(coin: coin)) {
                            CoinRowView(coin: coin)
                        }
                    }

                    if !viewModel.isLoading && viewModel.hasMorePages {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                            .onAppear {
                                Task {
                                    await viewModel.loadMoreCoins()
                                }
                            }
                    }
                }
            }
            .navigationTitle("Crypto Tracker")
            .searchable(text: $searchText, prompt: "Search coins...")
            .refreshable {
                await viewModel.refreshCoins()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingPortfolio.toggle()
                    } label: {
                        Image(systemName: "briefcase")
                    }
                }
            }
            .sheet(isPresented: $showingPortfolio) {
                PortfolioView()
            }
            .alert("Error", isPresented: $viewModel.showError, presenting: viewModel.errorMessage) { _ in
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: { errorMessage in
                Text(errorMessage)
            }
        }
        .task {
            await viewModel.loadCoins()
        }
    }

    var filteredCoins: [Coin] {
        if searchText.isEmpty {
            return viewModel.coins
        } else {
            return viewModel.coins.filter { coin in
                coin.name.localizedCaseInsensitiveContains(searchText) ||
                coin.symbol.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

@MainActor
class CoinListViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var currentPage = 1
    @Published var hasMorePages = true

    private let service = CoinGeckoService.shared

    func loadCoins() async {
        guard !isLoading else { return }
        isLoading = true

        do {
            let fetchedCoins = try await service.fetchCoins(page: 1)
            coins = fetchedCoins
            currentPage = 1
            hasMorePages = fetchedCoins.count == 100
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func loadMoreCoins() async {
        guard !isLoading && hasMorePages else { return }
        isLoading = true

        do {
            let nextPage = currentPage + 1
            let fetchedCoins = try await service.fetchCoins(page: nextPage)
            coins.append(contentsOf: fetchedCoins)
            currentPage = nextPage
            hasMorePages = fetchedCoins.count == 100
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func refreshCoins() async {
        await loadCoins()
    }
}
import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

class CoinGeckoService: ObservableObject {
    static let shared = CoinGeckoService()
    private let baseURL = "https://api.coingecko.com/api/v3"
    private let session = URLSession.shared

    private init() {}

    func fetchCoins(page: Int = 1, perPage: Int = 100) async throws -> [Coin] {
        guard let url = URL(string: "\(baseURL)/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=\(perPage)&page=\(page)&sparkline=true&price_change_percentage=7d") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.networkError("Invalid response")
            }

            let decoder = JSONDecoder()
            let coins = try decoder.decode([Coin].self, from: data)
            return coins
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.decodingError
            }
        }
    }

    func fetchCoinDetail(id: String) async throws -> CoinDetail {
        guard let url = URL(string: "\(baseURL)/coins/\(id)?localization=false&tickers=false&market_data=true&community_data=false&developer_data=false&sparkline=false") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.networkError("Invalid response")
            }

            let decoder = JSONDecoder()
            let coinDetail = try decoder.decode(CoinDetail.self, from: data)
            return coinDetail
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.decodingError
            }
        }
    }

    func fetchMarketChart(id: String, days: Int = 7) async throws -> MarketChart {
        guard let url = URL(string: "\(baseURL)/coins/\(id)/market_chart?vs_currency=usd&days=\(days)") else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw APIError.networkError("Invalid response")
            }

            let decoder = JSONDecoder()
            let chart = try decoder.decode(MarketChart.self, from: data)
            return chart
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.decodingError
            }
        }
    }

    func searchCoins(query: String) async throws -> [Coin] {
        let allCoins = try await fetchCoins(perPage: 250)
        let filteredCoins = allCoins.filter { coin in
            coin.name.lowercased().contains(query.lowercased()) ||
            coin.symbol.lowercased().contains(query.lowercased())
        }
        return filteredCoins
    }
}
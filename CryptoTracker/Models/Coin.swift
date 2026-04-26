import Foundation

struct Coin: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let currentPrice: Double
    let marketCap: Double
    let marketCapRank: Int
    let fullyDilutedValuation: Double?
    let totalVolume: Double
    let high24H: Double?
    let low24H: Double?
    let priceChange24H: Double?
    let priceChangePercentage24H: Double?
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply: Double
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double
    let athChangePercentage: Double
    let athDate: String
    let atl: Double
    let atlChangePercentage: Double
    let atlDate: String
    let lastUpdated: String
    let sparklineIn7D: SparklineIn7D?
    let priceChangePercentage7DInCurrency: Double?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image
        case currentPrice = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case fullyDilutedValuation = "fully_diluted_valuation"
        case totalVolume = "total_volume"
        case high24H = "high_24h"
        case low24H = "low_24h"
        case priceChange24H = "price_change_24h"
        case priceChangePercentage24H = "price_change_percentage_24h"
        case marketCapChange24H = "market_cap_change_24h"
        case marketCapChangePercentage24H = "market_cap_change_percentage_24h"
        case circulatingSupply = "circulating_supply"
        case totalSupply = "total_supply"
        case maxSupply = "max_supply"
        case ath
        case athChangePercentage = "ath_change_percentage"
        case athDate = "ath_date"
        case atl
        case atlChangePercentage = "atl_change_percentage"
        case atlDate = "atl_date"
        case lastUpdated = "last_updated"
        case sparklineIn7D = "sparkline_in_7d"
        case priceChangePercentage7DInCurrency = "price_change_percentage_7d_in_currency"
    }

    var formattedPrice: String {
        "$\(currentPrice.formatted(.number.precision(.fractionLength(2...6))))"
    }

    var priceChangeColor: String {
        (priceChangePercentage24H ?? 0) >= 0 ? "green" : "red"
    }
}

struct SparklineIn7D: Codable {
    let price: [Double]
}

struct CoinDetail: Codable {
    let id: String
    let symbol: String
    let name: String
    let description: Description
    let image: Image
    let marketData: MarketData?

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, description, image
        case marketData = "market_data"
    }

    struct Description: Codable {
        let en: String
    }

    struct Image: Codable {
        let thumb: String
        let small: String
        let large: String
    }

    struct MarketData: Codable {
        let currentPrice: [String: Double]
        let priceChangePercentage24H: Double?
        let priceChangePercentage7D: Double?
        let priceChangePercentage30D: Double?
        let priceChangePercentage1Y: Double?

        enum CodingKeys: String, CodingKey {
            case currentPrice = "current_price"
            case priceChangePercentage24H = "price_change_percentage_24h"
            case priceChangePercentage7D = "price_change_percentage_7d"
            case priceChangePercentage30D = "price_change_percentage_30d"
            case priceChangePercentage1Y = "price_change_percentage_1y"
        }
    }
}

struct MarketChart: Codable {
    let prices: [[Double]]
    let marketCaps: [[Double]]
    let totalVolumes: [[Double]]

    enum CodingKeys: String, CodingKey {
        case prices
        case marketCaps = "market_caps"
        case totalVolumes = "total_volumes"
    }

    var priceData: [ChartData] {
        prices.map { ChartData(timestamp: Date(timeIntervalSince1970: $0[0] / 1000), value: $0[1]) }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let timestamp: Date
    let value: Double
}
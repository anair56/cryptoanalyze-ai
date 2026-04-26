import Foundation
import SwiftData

@Model
class PortfolioItem {
    var coinId: String
    var coinSymbol: String
    var coinName: String
    var quantity: Double
    var averagePurchasePrice: Double
    var dateAdded: Date

    init(coinId: String, coinSymbol: String, coinName: String, quantity: Double, averagePurchasePrice: Double) {
        self.coinId = coinId
        self.coinSymbol = coinSymbol
        self.coinName = coinName
        self.quantity = quantity
        self.averagePurchasePrice = averagePurchasePrice
        self.dateAdded = Date()
    }

    var totalCost: Double {
        quantity * averagePurchasePrice
    }

    func currentValue(at price: Double) -> Double {
        quantity * price
    }

    func profitLoss(at price: Double) -> Double {
        currentValue(at: price) - totalCost
    }

    func profitLossPercentage(at price: Double) -> Double {
        guard totalCost > 0 else { return 0 }
        return (profitLoss(at: price) / totalCost) * 100
    }
}
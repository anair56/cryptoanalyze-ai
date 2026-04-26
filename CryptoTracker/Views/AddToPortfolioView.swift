import SwiftUI
import SwiftData

struct AddToPortfolioView: View {
    let coin: Coin
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var quantity: String = ""
    @State private var purchasePrice: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var totalCost: Double {
        let qty = Double(quantity) ?? 0
        let price = Double(purchasePrice) ?? 0
        return qty * price
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        AsyncImage(url: URL(string: coin.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Circle()
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .frame(width: 40, height: 40)

                        VStack(alignment: .leading) {
                            Text(coin.symbol.uppercased())
                                .font(.headline)
                            Text(coin.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Current Price")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(coin.formattedPrice)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Section("Transaction Details") {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("0.0", text: $quantity)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        TextField("$0.00", text: $purchasePrice)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    Button {
                        purchasePrice = String(coin.currentPrice)
                    } label: {
                        Text("Use Current Price")
                            .font(.caption)
                    }
                }

                Section("Summary") {
                    HStack {
                        Text("Total Cost")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("$\(totalCost, specifier: "%.2f")")
                            .fontWeight(.semibold)
                    }
                }
            }
            .navigationTitle("Add to Portfolio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addToPortfolio()
                    }
                    .fontWeight(.semibold)
                    .disabled(quantity.isEmpty || purchasePrice.isEmpty)
                }
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    func addToPortfolio() {
        guard let qty = Double(quantity), qty > 0 else {
            alertMessage = "Please enter a valid quantity"
            showingAlert = true
            return
        }

        guard let price = Double(purchasePrice), price > 0 else {
            alertMessage = "Please enter a valid purchase price"
            showingAlert = true
            return
        }

        let portfolioItem = PortfolioItem(
            coinId: coin.id,
            coinSymbol: coin.symbol,
            coinName: coin.name,
            quantity: qty,
            averagePurchasePrice: price
        )

        modelContext.insert(portfolioItem)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "Failed to save portfolio item"
            showingAlert = true
        }
    }
}
import SwiftUI

struct CoinRowView: View {
    let coin: Coin

    var body: some View {
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

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(coin.symbol.uppercased())
                        .font(.headline)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text(coin.name)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack {
                    Text("Rank: \(coin.marketCapRank)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(coin.formattedPrice)
                    .font(.headline)

                HStack(spacing: 4) {
                    Image(systemName: (coin.priceChangePercentage24H ?? 0) >= 0 ? "triangle.fill" : "triangle.down.fill")
                        .font(.caption)
                        .rotationEffect(.degrees((coin.priceChangePercentage24H ?? 0) >= 0 ? 0 : 180))

                    Text("\(abs(coin.priceChangePercentage24H ?? 0), specifier: "%.2f")%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor((coin.priceChangePercentage24H ?? 0) >= 0 ? .green : .red)
            }
        }
        .padding(.vertical, 4)
    }
}
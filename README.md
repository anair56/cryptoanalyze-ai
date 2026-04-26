# CryptoTracker - iOS Crypto Portfolio App

A SwiftUI-based iOS application for tracking cryptocurrency prices and managing a virtual portfolio.

## Features

- **Real-time Crypto Prices**: Fetches live cryptocurrency data from CoinGecko API
- **Price Charts**: Interactive price charts with multiple timeframes (24H, 7D, 30D, 1Y)
- **Portfolio Tracking**: Add cryptocurrencies to your virtual portfolio and track profit/loss
- **Search Functionality**: Search through hundreds of cryptocurrencies
- **Detailed Coin View**: View comprehensive statistics, market data, and descriptions for each coin
- **SwiftData Integration**: Local storage for portfolio data using Apple's modern persistence framework

## Technical Stack

- **SwiftUI**: Modern declarative UI framework
- **Swift Charts**: Native charting for price visualization
- **SwiftData**: Data persistence for portfolio management
- **Async/Await**: Modern Swift concurrency for API calls
- **MVVM Architecture**: Clean separation of concerns

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Internet connection for API calls

## Project Structure

```
CryptoTracker/
├── Models/
│   ├── Coin.swift           # Cryptocurrency data models
│   └── Portfolio.swift      # Portfolio item model with SwiftData
├── Services/
│   └── CoinGeckoService.swift  # API service for fetching crypto data
├── Views/
│   ├── CoinListView.swift      # Main list of cryptocurrencies
│   ├── CoinRowView.swift       # Individual coin row component
│   ├── CoinDetailView.swift    # Detailed coin view with charts
│   ├── PortfolioView.swift     # Portfolio management view
│   └── AddToPortfolioView.swift # Add coins to portfolio
└── CryptoTrackerApp.swift      # App entry point

```

## Setup Instructions

1. Open `CryptoTracker.xcodeproj` in Xcode
2. Build and run the project (⌘+R)
3. The app uses the free CoinGecko API (no API key required)

## API Usage

The app uses the CoinGecko API v3:
- Market data: `/coins/markets`
- Coin details: `/coins/{id}`
- Price charts: `/coins/{id}/market_chart`

## Features in Detail

### Main Screen
- Displays top cryptocurrencies by market cap
- Pull to refresh for latest data
- Infinite scrolling with pagination
- Search bar for filtering coins

### Coin Detail View
- Current price with 24h change
- Interactive price chart with selectable timeframes
- Market statistics (market cap, volume, supply)
- Coin description
- Add to portfolio button

### Portfolio Management
- Track multiple cryptocurrencies
- Enter purchase price and quantity
- Real-time profit/loss calculation
- Portfolio summary with total value
- Swipe to delete portfolio items

## Note

This app uses the free tier of CoinGecko API which has rate limits. For production use, consider implementing caching and rate limiting strategies.
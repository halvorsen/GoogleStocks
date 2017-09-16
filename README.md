# GoogleStocks

[![CI Status](http://img.shields.io/travis/halvorsen/GoogleStocks.svg?style=flat)](https://travis-ci.org/halvorsen/GoogleStocks)
[![Version](https://img.shields.io/cocoapods/v/GoogleStocks.svg?style=flat)](http://cocoapods.org/pods/GoogleStocks)
[![License](https://img.shields.io/cocoapods/l/GoogleStocks.svg?style=flat)](http://cocoapods.org/pods/GoogleStocks)
[![Platform](https://img.shields.io/cocoapods/p/GoogleStocks.svg?style=flat)](http://cocoapods.org/pods/GoogleStocks)

#<p align="center">
#<img src="http://aaronhalvorsen.com/resources/GoogleStocks.gif" width="375" height="667" alt="DynamicButton" />
#</p>

***Google Finance API no longer working.***

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

`import GoogleStocks`

v 0.1.0 includes two functions to retrieve historical data and a stock's current price. There is an example graph in the example project:

Historical prices

`historicalPrices(years: Int, ticker: String, result: @escaping (_ stockDataTuple:([Double]?,[(String,Int,Int)]?,Error?)) -> Void)`

For Example: 

```swift
StockPrices.shared.historicalPrices(years: 10, ticker: "TSLA") { (_stockData,_dates,error) in
if error != nil {
print(error?.localizedDescription)
} else {
guard let stockData = _stockData else {return}
guard let dates = _dates else {return}
print("Stock Prices As Doubles::::")
print(stockData)
print("Stock Prices As Strings::::")
print(stockData.map {"$" + String(format: "%.02f", $0)})
print("Stock Dates::::")
print(dates)
}
```

Current price displays current value when stock market is open, last closing price if it is closed

`currentPrice(ticker: String, done: @escaping ((Double,String,Int,Int)?,Error?) -> Void)`

For Example:

```swift
StockPrices.shared.currentPrice(ticker: "TSLA") { (tuple, error) in

if error != nil {
print(error!.localizedDescription)
} else {
guard let (price, month, day, year) = tuple else {return}

print("Stock Prices As Double::::")
print(price)
print("Stock Price As String::::")
print("$" + String(format: "%.02f", price))
print("Stock Date::::")
print("\(month) \(day), \(year)")
}
}
```

*GoogleStocks is meant for personal use and not production use, here is the cheapest option I've found for production:
Intrinio.com, $250/month for up to 100,000 api calls/day for startups.

## Requirements

## Installation

GoogleStocks is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GoogleStocks"
```

## Author

halvorsen, “aaron.halvorsen@gmail.com
git config --global user.name  “halvorsen

## License

GoogleStocks is available under the MIT license. See the LICENSE file for more info.

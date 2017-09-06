//
//  StockPrices.swift
//  Pods
//
//  Created by Aaron Halvorsen on 7/26/17.
//
//

import Foundation

public class StockPrices {
    public static var shared = StockPrices()
    var _years = Int()
    var monthAndDay = [(String,Int,Int)]()
    var closingPrices = [Double]()
    var basket = [Int:[(Double,String,Int,Int)]]()
    var count = 0
    let monthStrings = ["zero","Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
    
    public func historicalPrices(years: Int, ticker: String, result: @escaping (_ stockDataTuple:([Double]?,[(String,Int,Int)]?,Error?)) -> Void) {
        _years = years
        
        let index = getIndex(ticker: ticker)
        
        var start = DateComponents()
        var end = DateComponents()
        
        start.year = -years
        end.year = 0
        
        fetchFromGoogle(yearStart: years, dateComponentStart: start, dateComponentEnd: end, ticker: ticker, index: index) {
            
            self.currentPrice(ticker: ticker) {(tuple, error) in
                guard let data = tuple else {return}
                let (lastPrice,monthToday,dayToday,yearToday) = data
                
                self.basket[1] = [(lastPrice,monthToday,dayToday,yearToday)]
                
                for i in 0...1 {
                    for (price,month,day,year) in self.basket[i]!.reversed() {
                        self.closingPrices.append(price)
                        self.monthAndDay.append((month,day,year))
                    }
                }
               
                result((self.closingPrices,self.monthAndDay,nil))
            }
        }
        
    }
    
    var errorInSecondFetch = false
    var error2: Error?
    
    private func fetchFromGoogle(yearStart: Int, dateComponentStart: DateComponents, dateComponentEnd: DateComponents, ticker: String, index: String, result2: @escaping () -> Void) {
        
        let endDate = Calendar.current.date(byAdding: dateComponentEnd, to: Date())
        let endDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: endDate!)
        let startDate = Calendar.current.date(byAdding: dateComponentStart, to: endDate!)
        let startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate!)
        let startDateMonth = monthStrings[startDateComponents.month!]
        let startDateYear = String(describing: startDateComponents.year!)
        let startDateDay = String(describing: startDateComponents.day!)
        let endDateMonth = monthStrings[endDateComponents.month!]
        let endDateYear = String(describing: endDateComponents.year!)
        let endDateDay = String(describing: endDateComponents.day!)
        let stringComponents: [String] = ["https://www.google.com/finance/historical?q=",index,":",ticker,"&startdate=",startDateMonth,"+",startDateDay,"%2C+",startDateYear,"&enddate=",endDateMonth,"+",endDateDay,"%2C+",endDateYear,"&output=csv"]
        
        let urlString = stringComponents.flatMap({$0}).joined()
        let url = URL(string: urlString)
        var priceData = [(Double,String,Int,Int)]()
        
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                if error != nil {
                    self.errorInSecondFetch = true
                    print(error!.localizedDescription)
                    self.error2 = error!
                    
                }
                if let data = data {
                    if let stringData = String(data: data, encoding: String.Encoding.utf8) {
                        let dataInArrays = self.csv(data: stringData)
                        guard dataInArrays.count > 2 else {print("google data request error"); return}
                        for i in 1...(dataInArrays.count-2) {
                            if let _dataInArrays = Double(dataInArrays[i][4]) {
                                let myd = dataInArrays[i][0].characters.map { String($0) }
                                var m = String()
                                var d = String()
                                var y = String()
                                var dash = 0
                                for char in myd {
                                    if char != "-" && dash == 0 {
                                        d.append(char)
                                    } else if char != "-" && dash == 1 {
                                        m.append(char)
                                    } else if char != "-" && dash == 2 {
                                        y.append(char)
                                    } else {
                                        dash += 1
                                    }
                                }
                                
                                priceData.append((_dataInArrays,m,Int(d)!,Int(y)! + 2000))
                                
                            }
                        }
                        
                        self.basket[0] = priceData
                        result2()
                    }
                }
            })
            task.resume()
            
        }
    }
    
    public func currentPrice(ticker: String, done: @escaping ((Double,String,Int,Int)?,Error?) -> Void) {
        
        let index = getIndex(ticker: ticker)
        
        var url = URL(string: "https://www.google.com/finance/info?q=" + ticker)
        if index.lowercased() == "otcmkts" {
         url = URL(string: "https://www.google.com/finance/info?q=" + index + ":" + ticker)
        }
        if let usableUrl = url {
            let request = URLRequest(url: usableUrl)
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
                
                
                if error != nil {
                    print("Error from Google Request of current price: \(error!)")
                    done(nil,error)
                }
                var stringData = String()
                var stringPrice = String()
                if let data = data {
                    if let _stringData = String(data: data, encoding: String.Encoding.utf8) {
                        stringData = _stringData
                        
                    }
                }
                
                let arrayData = Array(stringData.characters)
                
                dance: for i in 0..<arrayData.count {
                    if arrayData[i] == "l" {
                        if arrayData[i+1] == "\"" {
                            for j in 0...10 {
                                if arrayData[i+j+6] == "\"" {break dance}
                                if arrayData[i+j+6] != "," {
                                    stringPrice += String(arrayData[i+j+6])
                                }
                            }
                        }
                    }
                }
                
                //check if error occured in historical fetch
                if self.errorInSecondFetch {
                    print("Error from Google Request of historical prices: \(self.error2!)")
                    done(nil,self.error2)
                }
                
                let componentDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                let monthToday = self.monthStrings[componentDate.month!]
                let dayToday = componentDate.day!
                let yearToday = componentDate.year!
                
                guard let lastPrice = Double(stringPrice) else {print("g1");return}
                
                
                
                
                
                done((lastPrice,monthToday,dayToday,yearToday),nil)
                
                
            })
            
            task.resume()
        }
        
    }
    
    private func getIndex(ticker: String) -> String {
     
        if IndexListOfStocks.nasdaq.contains(ticker) {
            return "NASDAQ"
        } else if IndexListOfStocks.nyse.contains(ticker) {
            return "NYSE"
        } else if IndexListOfStocks.amex.contains(ticker) {
            return "AMEX"
        } else if IndexListOfStocks.otcmkts.contains(ticker) {
            return "OTCMKTS"
        }
       return ""
    }
    
    private func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
}

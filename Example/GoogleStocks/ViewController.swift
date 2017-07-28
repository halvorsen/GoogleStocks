//
//  ViewController.swift
//  GoogleStocks
//
//  Created by halvorsen on 07/26/2017.
//  Copyright (c) 2017 halvorsen. All rights reserved.
//

import UIKit
import GoogleStocks

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(colorLiteralRed: 50/255, green: 50/255, blue: 50/255, alpha: 1.0)
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
                
                
                
                let graph = OneMonthGraphView(graphData: Array(stockData.suffix(20)), dateArray: Array(dates.suffix(20)))
                
                
                let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: graph.bounds.height))
                scroll.contentSize = graph.bounds.size
                self.view.addSubview(scroll)
                scroll.addSubview(graph)
                
                UIView.animate(withDuration: 3.0) {
                    scroll.contentOffset.x = scroll.contentSize.width - UIScreen.main.bounds.width
                }
                
            }
        }
        
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
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


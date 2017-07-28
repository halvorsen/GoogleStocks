//
//  OneMonthGraphView.swift
//  GoogleStocks
//
//  Created by Aaron Halvorsen on 7/28/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

class OneMonthGraphView: UIView {
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    let fontSizeMultiplier = UIScreen.main.bounds.width / 375
    var yScrollCenterLocation: CGFloat = 3000*UIScreen.main.bounds.height/600
    var __set = [CGFloat]()
    var passedColor = UIColor()
    let scale: CGFloat = 4
    var stock = ""
    var pointSet = [CGFloat]()
    var labels = [UILabel]()
    var allStockValues = [String]()
    var grids = [GridLine]()
    var dayLabels = [UILabel]()
    var month = [String]()
    var day = [Int]()
    
    
    init() {super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))}
    
    init(graphData: [Double], dateArray: [(String,Int,Int)], frame: CGRect = CGRect(x: 0, y:0, width: 4*UIScreen.main.bounds.width, height: 667*UIScreen.main.bounds.height/667)) {
        
        super.init(frame: frame)
        self.backgroundColor = UIColor(red: 228/255, green: 81/255, blue: 81/255, alpha: 1.0)
        var _graphData = [Double]()
        var a = 0; if String(format:"%.2f", graphData[dateArray.count-1]) == String(format:"%.2f", graphData[dateArray.count-2]) { a = 1 }
        for i in 0..<20 {
            month.append(dateArray[dateArray.count-20+i-a].0)
            day.append(dateArray[dateArray.count-20+i-a].1)
            _graphData.append(graphData[dateArray.count-20+i-a])
        }
        
        // print("month: \(month), day: \(day), price \(_graphData)")
        var _set = [Double]()
        let max = _graphData.max()!
        let min = _graphData.min()!
        let range = max - min
        let x = 59*screenHeight/667
        let y = 140*screenHeight/667
        _set = _graphData.map {1 - ($0 - min / range) } // values go from 0 to 1
        pointSet = _set.map { CGFloat(x + CGFloat($0)*y) }
        __set = [pointSet.first!] + pointSet + [pointSet.last!] //adds extra datapoint to make quadratic curves look good on ends
        
        data = _graphData.map {CGFloat(($0-min)/range)}
        allStockValues = _graphData.map {String(format:"%.2f", $0)}
  
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.translateBy(x: 0, y: 5)
        ctx!.scaleBy(x: scale, y: 0.9*scale)
        let path = quadCurvedPath()
        path.addLine(to: CGPoint(x: points.last!.x + 200, y: points.last!.y))
        path.addLine(to: CGPoint(x: points.last!.x + 200, y: -10))
        path.addLine(to: CGPoint(x: 0, y: -10))
        path.addLine(to: CGPoint(x: 0, y: points.last!.y))
        path.addLine(to: points.first!)
        path.close()

        UIColor(colorLiteralRed: 21/255, green: 21/255, blue: 21/255, alpha: 1.0).setFill()
        path.lineWidth = 1
        path.fill()
        
        for i in 1..<points.count {
            drawPoint(point: points[i], color: .white, radius: 1)
            
        }
        
        
    }
    
    var data: [CGFloat] = [0, 0, 0, 0, 0, 0] //{
    
    func coordXFor(index: Int) -> CGFloat {
        return bounds.height / scale - (bounds.height/scale) * data[index] / (data.max() ?? 0)
    }
    
    
    var points = [CGPoint]()
    func quadCurvedPath() -> UIBezierPath {
        let path = UIBezierPath()
        let step = bounds.width / CGFloat(data.count - 1) / (scale * 1.1)
        
        var p1 = CGPoint(x: 0, y: coordXFor(index: 0))
        points.append(p1)
        path.move(to: p1)
        
        //drawPoint(point: p1, color: .white, radius: 1)
        
        if (data.count == 2) {
            path.addLine(to: CGPoint(x: step, y: coordXFor(index: 1)))
            return path
        }
        
        var oldControlP: CGPoint?
        
        for i in 1..<data.count {
            let p2 = CGPoint(x: step * CGFloat(i), y: coordXFor(index: i))
            //     drawPoint(point: p2, color: .white, radius: 1)
            points.append(p2)
            var p3: CGPoint?
            if i == data.count - 1 {
                p3 = nil
            } else {
                p3 = CGPoint(x: step * CGFloat(i + 1), y: coordXFor(index: i + 1))
            }
            
            let newControlP = controlPointForPoints(p1: p1, p2: p2, p3: p3)
            
            path.addCurve(to: p2, controlPoint1: oldControlP ?? p1, controlPoint2: newControlP ?? p2)
            
            p1 = p2
            oldControlP = imaginFor(point1: newControlP, center: p2)
            
        }

        
        return path;
    }
    
    func imaginFor(point1: CGPoint?, center: CGPoint?) -> CGPoint? {
        guard let p1 = point1, let center = center else {
            return nil
        }
        let newX = 2 * center.x - p1.x
        let diffY = abs(p1.y - center.y)
        let newY = center.y + diffY * (p1.y < center.y ? 1 : -1)
        
        return CGPoint(x: newX, y: newY)
    }
    
    func midPointForPoints(p1: CGPoint, p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2);
    }
    
    func controlPointForPoints(p1: CGPoint, p2: CGPoint, p3: CGPoint?) -> CGPoint? {
        guard let p3 = p3 else {
            return nil
        }
        
        let leftMidPoint  = midPointForPoints(p1: p1, p2: p2)
        let rightMidPoint = midPointForPoints(p1: p2, p2: p3)
        
        var controlPoint = midPointForPoints(p1: leftMidPoint, p2: imaginFor(point1: rightMidPoint, center: p2)!)
        
        
        // this part needs for optimization
        
        if p1.y < p2.y {
            if controlPoint.y < p1.y {
                controlPoint.y = p1.y
            }
            if controlPoint.y > p2.y {
                controlPoint.y = p2.y
            }
        } else {
            if controlPoint.y > p1.y {
                controlPoint.y = p1.y
            }
            if controlPoint.y < p2.y {
                controlPoint.y = p2.y
            }
        }
        
        let imaginContol = imaginFor(point1: controlPoint, center: p2)!
        if p2.y < p3.y {
            if imaginContol.y < p2.y {
                controlPoint.y = p2.y
            }
            if imaginContol.y > p3.y {
                let diffY = abs(p2.y - p3.y)
                controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
            }
        } else {
            if imaginContol.y > p2.y {
                controlPoint.y = p2.y
            }
            if imaginContol.y < p3.y {
                let diffY = abs(p2.y - p3.y)
                controlPoint.y = p2.y + diffY * (p3.y < p2.y ? 1 : -1)
            }
        }
        
        return controlPoint
    }
    
    func drawPoint(point: CGPoint, color: UIColor, radius: CGFloat) {
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
        color.setFill()
        ovalPath.fill()
    }
    
}


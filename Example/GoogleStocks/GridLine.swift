//
//  GridLine.swift
//  firetail
//
//  Created by Aaron Halvorsen on 3/16/17.
//  Copyright © 2017 Aaron Halvorsen. All rights reserved.
//

import UIKit

class GridLine: UIView {

    override init(frame: CGRect = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width/750, height: 260*UIScreen.main.bounds.height/667)) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 255/255, blue: 255/255, alpha: 0.1)
        self.alpha = 0.0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

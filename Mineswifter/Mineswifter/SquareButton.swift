//
//  SquareButton.swift
//  Minesweeper
//
//  Created by Venkata Bharani Krishna Chekuri on 4/12/16.
//  Copyright © 2016 Venkata Bharani Krishna Chekuri. All rights reserved.
//

// Each SquareButton will be associated to a Square. So the Square will be holding
// the values while the SquareButton will be responsible for the display.

import Foundation
import UIKit

class SquareButton : UIButton {
    let squareSize : CGFloat
    var square : Square
    
    init(squareModel : Square, squareSize : CGFloat) {
        self.square = squareModel
        self.squareSize = squareSize
        let x = CGFloat(self.square.col) * (squareSize)
        let y = CGFloat(self.square.row) * (squareSize)
        let squareFrame = CGRectMake(x, y, squareSize, squareSize)
        super.init(frame : squareFrame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
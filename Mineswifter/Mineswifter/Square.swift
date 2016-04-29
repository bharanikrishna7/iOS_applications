//
//  Square.swift
//  Minesweeper
//
//  Created by Venkata Bharani Krishna Chekuri on 4/12/16.
//  Copyright © 2016 Venkata Bharani Krishna Chekuri. All rights reserved.
//

// The Square will be responsible for holding the values of mines,
// neighbouring mine count (if not a mine), is the square revealed ?,
// is it marked ? and also the row and column in the Minesweeper matrix.

import Foundation

class Square {
    let row: Int                                    // Row of the Square in the grid
    let col: Int                                    // Column of the Square in the grid
    var NeighbouringMines = 0                       // Number of neighbouring mines to this Square
    var isMine = false                              // Is this Square a mine ?
    var isRevealed = false                          // Is this Square revealed ?
    var isMarked = false                            // Is this Square marked ?
    
    // Initialize function
    init(row: Int, col: Int) {                      // Initialize the class with a row and col value
        self.row = row
        self.col = col
    }
}
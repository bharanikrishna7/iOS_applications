//
//  Board.swift
//  Minesweeper
//
//  Created by Venkata Bharani Krishna Chekuri on 4/12/16.
//  Copyright © 2016 Venkata Bharani Krishna Chekuri. All rights reserved.
//

// Board will be a collection of squares which will contain
// methods to generate a Minesweeper game Backend i.e mines,
// updating neighbouring mine count, functions for reset board etc.

import Foundation

class Board {
    let size : Int                      // The size of the Board
    let mines : Int                     // Number of Mines in the Board
    var grids : [[Square]] = []         // The variable which will store the size * size Squares
    
    // VERBOSE [Helps in debugging by Visualizig what is exactly going on in the program]
    var VERBOSE : Bool = false
    
    
    // Initialize function
    init(size: Int) {                   // Initialize the size of the board with value size
        if VERBOSE {
            print("Function : init\tClass : Board")
        }
        
        self.size = size
        self.mines = (self.size * self.size * 15) / 100
        setBoard()
    }
    
    // This will create all the Squares/ Grids required for the Board and
    // set up the row and col values in each of them
    func setBoard() {
        if VERBOSE {
            print("Function : setBoard\tClass : Board")
        }
        
        // Remove all elements in the grid (Just a precautionary measure)
        grids.removeAll()
        // Adds [Squares] to grids size # times. Thereby generating size * size grids
        for _row in 0..<self.size {
            var SquareRow: [Square] = []
            for _col in 0..<self.size {
                SquareRow.append(Square(row: _row, col: _col))
            }
            grids.append(SquareRow)
        }
    }
    
    // This function will reset the Squares/ Grid values in the Board
    func resetBoard() {
        if VERBOSE {
            print("Function : resetBoard\tClass : Board")
        }
        
        for _row in 0..<self.size {
            for _col in 0..<self.size {
                grids[_row][_col].isMine = false
                grids[_row][_col].isRevealed = false
                grids[_row][_col].NeighbouringMines = 0
            }
        }
        
        setMines()                                      // Set random Squares as mines in the Grid (15 % of the square of Size of Grid
        computeNeighbourMineCount()                     // Compute the neighbour mine count for all the Squares and set it to the computed value
        
        if VERBOSE {
            print("Mines are Set.\nNeighbours are computed")
        }
    }
    
    // Randomly setting a Square to be a mine
    func setMines() {
        if VERBOSE {
            print("Function : setMines\tClass : Board")
        }
        
        for _ in 0..<self.mines {
            let _row = Int(arc4random_uniform(UInt32(self.size - 1)))
            let _col = Int(arc4random_uniform(UInt32(self.size - 1)))
            grids[_row][_col].isMine = true
            grids[_row][_col].NeighbouringMines = -1
        }
    }
    
    // Returns an array of Squares which are neighbours to the given "square"
    func getNeighbours(square : Square) -> [Square] {
        if VERBOSE {
            print("Function : getNeighbours\tClass : Board")
        }
        
        var neighbours : [Square] = []
        let adjacents = [(-1, -1), (-1, 0), (-1, 1), (0, 1), (1, 1), (1, 0), (1, -1), (0, -1)]
        
        // Check if the neighbour nodes are valid, and if they are then add
        // it to the array neighbours
        for(ra, ca)in adjacents {
            if(square.row - ra >= 0 && square.row - ra < self.size) {
                if(square.col - ca >= 0 && square.col - ca < self.size) {
                    neighbours.append(self.grids[square.row - ra][square.col - ca])
                }
            }
        }
        
        return neighbours
    }
    
    // Compute the values of Neighbouring Mines for all the Squares in the Grid
    func computeNeighbourMineCount() {
        if VERBOSE {
            print("Function : computeNeighbourMineCount\tClass : Board")
        }
        
        for _row in 0..<self.size {
            for _col in 0..<self.size {
                if(!self.grids[_row][_col].isMine) {
                    // Get the neighbours associated with this particular Square / Grid
                    let neighbours = getNeighbours(self.grids[_row][_col])
                    // Set the neighbour mine count to 0
                    self.grids[_row][_col].NeighbouringMines = 0
                    for neighbour in neighbours {
                        // If neighbouring Square is a mine then increment the neighbouring
                        // mine count
                        if (neighbour.isMine) {
                            self.grids[_row][_col].NeighbouringMines++
                        }
                    }
                }
            }
        }
    }
    
    // Return a specific Square present in the gird
    func getSquareAt(row : Int, col : Int) -> Square? {
        if VERBOSE {
            print("Function : getSquareAt\tClass : Board")
        }
        
        if(row >= 0 && row <= self.size) {
            if(col >= 0 && col <= self.size) {
                return grids[row][col]
            }
        }
        return nil
    }
    
    func setVERBOSE(verbose : Bool) {
        self.VERBOSE = verbose
    }
    
}
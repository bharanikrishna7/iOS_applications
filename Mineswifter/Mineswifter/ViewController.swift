//
//  ViewController.swift
//  Minesweeper
//
//  Created by Venkata Bharani Krishna Chekuri on 4/12/16.
//  Copyright © 2016 Venkata Bharani Krishna Chekuri. All rights reserved.
//
// ViewController class contains methods which will use the methods in the classes Board, Square and SquareButton
// to compute background values for the game and it'll implement a UI (View) with which the user will be able to 
// interact and play this game


import UIKit

class ViewController: UIViewController {
    // Referencing the bordView
    @IBOutlet weak var newGameButton: UIBarButtonItem!
    @IBOutlet weak var boardView: UIView!
    
    // VARIBLES
    let SIZE : Int = 10                             // The Dimension or Size of the Board
    var _Board : Board                              // Declaring a variable of type Board
    var squareButtons:[[SquareButton]] = []         // Declaring an array of [squareButtons]
    var MAX_MOVES : Int                             // Variable which will be holding the MAX_MOVES value
    var MOVES : Int = 0                             // Variable which will be holding the MOVES performed by the user
    var _SQUARES_MARKED : Int                       // Number of Mines - Number of Squares Marked
    var _CORRECT_MINES_MARKED : Int                 // Number of Mines - Number of Mines correctly marked
    let tapSingle = UITapGestureRecognizer()        // SingleTapGestureRecognizer
    let tapDouble = UITapGestureRecognizer()        // DoubleTapGestureRecognizer
    let tapLong = UILongPressGestureRecognizer()    // LongPressGestureRecognizer   (This is being used since Single Tap is not working)
                                                    // { But by setting the minimum press duration to be very low, we can mimic single tap }

    // VERBOSE [Helps in debugging by Visualizig what is exactly going on in the program]
    let VERBOSE : Bool = true
    
    override func viewDidLoad() {
        if VERBOSE {
            print("Function : viewDidLoad\tClass : ViewController")
        }
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Make double tap recognizable by the boardView
        tapDouble.addTarget(self, action: Selector("DoubleTap:"))
        tapDouble.numberOfTapsRequired = 2
        self.boardView.addGestureRecognizer(tapDouble)

        if VERBOSE {
            print("Double Tap gesture has been added to boardView")
        }
        
        /* Due to some Reason the Single Tap Gesture is not working */
        // Make single tap recognizable by the boardView
        tapSingle.addTarget(self, action: Selector("SingleTap:"))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.requireGestureRecognizerToFail(tapDouble)
        self.boardView.addGestureRecognizer(tapSingle)
        
        if VERBOSE {
            print("Single Tap gesture has been added to boardView")
        }
        
        // Make long press recognizable by the boardView
        tapLong.addTarget(self, action: Selector("SingleTap:"))
        tapLong.minimumPressDuration = 0.01
        tapLong.allowableMovement = 15
        tapLong.requireGestureRecognizerToFail(tapDouble)
        self.boardView.addGestureRecognizer(tapLong)
        
        if VERBOSE {
            print("Long Tap gesture (which mimics single tap) has been added to boardView")
        }
        
        self.initializeBoard()
        self.resetBoard()
    }
    
    override func didReceiveMemoryWarning() {
        if VERBOSE {
            print("Function : didReceiveMemoryWarning\tClass : ViewController")
        }
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Initialize all the unimitialized variables declared in the class ViewController
    required init?(coder aDecoder: NSCoder)
    {
        if VERBOSE {
            print("Function : init?\tClass : ViewController")
        }
        
        self._Board = Board(size: SIZE)
        // Setting the value of maxium moves required to finish the game
        let mineCount = (self.SIZE * self.SIZE * 15) / 100
        self.MAX_MOVES = self.SIZE * self.SIZE - mineCount
        self._SQUARES_MARKED = mineCount
        self._CORRECT_MINES_MARKED = mineCount
        super.init(coder: aDecoder)
    }
    
    func initializeBoard() {
        if VERBOSE {
            print("Function : initializeBoard\tClass : ViewController")
            self._Board.setVERBOSE(self.VERBOSE)
        }
        
        for row in 0 ..< _Board.size {
            var rowButtons: [SquareButton] = []
            for col in 0 ..< _Board.size {
                
                let square = _Board.grids[row][col]
                let squareSize : CGFloat = self.boardView.frame.width / CGFloat(SIZE)
                let squareButton = SquareButton(squareModel: square, squareSize: squareSize);
                // setting the View aspect of the squareButton [Color and Title]
                squareButton.setTitle("[x]", forState: .Normal)
                squareButton.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
                // Add action for when the squareButton is pressed
                //squareButton.addTarget(self, action: "squareButtonPressed:", forControlEvents: .TouchUpInside)
                squareButton.tag = row * 10 + col
                self.boardView.addSubview(squareButton)
                rowButtons.append(squareButton)
            }
            self.squareButtons.append(rowButtons)
         }
        self.view.bringSubviewToFront(boardView)
    }
    
    // This function will reset all the Grids in the board and also reset all the squareButtons
    // Will be called to start a new game
    func resetBoard() {
        if VERBOSE {
            print("Function : resetBoard\tClass : ViewController")
        }
        
        // resets the board with new mine locations & sets isRevealed to false for each square
        self._Board.resetBoard()
        // reset the moves count
        self.MOVES = 0
        // iterates through each button and resets the text to the default value
        for rowButtons in self.squareButtons {
            for squareButton in rowButtons {
                squareButton.setTitle("[x]", forState: .Normal)
            }
        }
        
        if VERBOSE {
            print("Reset board (New Game) operation has been completed")
        }
    }
    
    // Action for New Game UIButton
    @IBAction func newGamePressed(sender: UIBarButtonItem) {
        if VERBOSE {
            print("Function : newGamePressed\tClass : ViewController")
        }
        
        print("New Game")
        
        // Call reset board function
        self.resetBoard()
    }

    // Action when Double Tap gesture is recognized
    func DoubleTap(sender: UITapGestureRecognizer) {
        if VERBOSE {
            print("Function : DoubleTap\tClass : ViewController")
        }
        
        let cellSize = self.boardView.frame.width / CGFloat(SIZE)
        let row = Int(sender.locationInView(self.boardView).y / cellSize)
        let col = Int(sender.locationInView(self.boardView).x / cellSize)
        
        print("Double Tap")
        print("Clicked Row: \(row)  Col: \(col) ")
        
        // call revealMines function for the square at the tapped row and col
        self.revealSquare(row, col: col)
    }
    
    // Action when Single Tap gesture is recognized
    func SingleTap(sender: UITapGestureRecognizer) {
        if VERBOSE {
            print("Function : SingleTap\tClass : ViewController")
        }
        
        // Since we have added long tap's action as SingleTap() therefore we need to make
        // sure that this will activate processing only after the gesture has ended
        // else it'll be repeating the Action multiple times
        if ( sender.state == UIGestureRecognizerState.Ended )
        {
            let cellSize = self.boardView.frame.width / CGFloat(SIZE)
            let row = Int(sender.locationInView(self.boardView).y / cellSize)
            let col = Int(sender.locationInView(self.boardView).x / cellSize)

            print("Single Tap")
            print("Clicked Row: \(row)  Col: \(col) ")
        
            // call markMines function for the square at the tapped row and col
            self.markMine(row, col: col)
        }
    }
    
    // Function to reveal mine associated with square button at a specific row and column
    func revealSquare(row : Int, col : Int) {
        if VERBOSE {
            print("Function : revealSquare\tClass : ViewController")
            print("Square details : \nRow - \(row) Col - \(col)")
            print("IsMine - \(self.squareButtons[row][col].square.isMine.description)")
            print("isRevealed - \(self.squareButtons[row][col].square.isRevealed.description)")
        }
        
        // If selected Square is already Revealed
        if self.squareButtons[row][col].square.isRevealed {
            return
        }
        
        // If the selected square is a mine
        if self.squareButtons[row][col].square.isMine {
            self.squareButtons[row][col].setTitle(String("[-]"), forState: .Normal)
            let alertView = UIAlertView()
            alertView.addButtonWithTitle("New Game")
            alertView.title = "GAME OVER!"
            alertView.message = "You tapped a mine :("
            alertView.show()
            alertView.delegate = self
            return
        }
        
        // If the selected square is not Revealed
        if !self.squareButtons[row][col].square.isRevealed && !self.squareButtons[row][col].square.isMarked{
            // Increment Move count by 1
            self.MOVES = self.MOVES + 1
        
            self.squareButtons[row][col].square.isRevealed = true
            if (self.squareButtons[row][col].square.NeighbouringMines == 0) {
                self.squareButtons[row][col].setTitle(String(""), forState: .Normal)
                
                for neighbour in self._Board.getNeighbours(self._Board.grids[row][col]) {
                        self.revealSquare(neighbour.row, col: neighbour.col)
                }
                
            } else {
                self.squareButtons[row][col].setTitle(String(self.squareButtons[row][col].square.NeighbouringMines), forState: .Normal)
            }
        }
        
        /* Check the finish condition for the game
         * If the # MOVES = MAX_MOVES permitted then
         * the user has successfully finished game since
         * he has avoided all the mines
        */
        if (self.MOVES == self.MAX_MOVES) {
            // Game successfully completed alert
            let alertView = UIAlertView()
            alertView.addButtonWithTitle("New Game")
            alertView.title = "SUCCESS!"
            alertView.message = "You've finished the game B-)"
            alertView.show()
            alertView.delegate = self
            
            if VERBOSE {
                print("Game Successfully completed since the user has revealed all squares except mines")
            }
        }
    }
    
    // This function will help in marking the selected Square
    func markMine(row : Int, col : Int) {
        if VERBOSE {
            print("Function : revealSquare\tClass : ViewController")
            print("Square details : \nRow - \(row) Col - \(col)")
            print("IsMine - \(self.squareButtons[row][col].square.isMine.description)")
            print("isRevealed - \(self.squareButtons[row][col].square.isRevealed.description)")
            print("IsMarked - \(self.squareButtons[row][col].square.isMarked.description)")
        }

        if !self.squareButtons[row][col].square.isRevealed {
            
            // If the square which is selected is already marked
            if self.squareButtons[row][col].square.isMarked {
                self.squareButtons[row][col].square.isMarked = false
                self.squareButtons[row][col].setTitle(String("[x]"), forState: .Normal)
                
                self._SQUARES_MARKED = self._SQUARES_MARKED + 1
                
                if self.squareButtons[row][col].square.isMine {
                    self._CORRECT_MINES_MARKED = self._CORRECT_MINES_MARKED + 1
                }
                
                self.checkMarkEndCondition()
                return
            }
            
            if !self.squareButtons[row][col].square.isMarked {
            // If the square which is selected is not marked
                self.squareButtons[row][col].square.isMarked = true
                self.squareButtons[row][col].setTitle(String("[M]"), forState: .Normal)
                
                self._SQUARES_MARKED = self._SQUARES_MARKED - 1
                
                if self.squareButtons[row][col].square.isMine {
                    self._CORRECT_MINES_MARKED = self._CORRECT_MINES_MARKED - 1
                }
                
                self.checkMarkEndCondition()
                return
            }
        }
    }
    
    func checkMarkEndCondition() {
        if VERBOSE {
            print("Function : revealSquare\tClass : ViewController")
        }
        
        if (self._SQUARES_MARKED == 0 && self._CORRECT_MINES_MARKED == 0) {
            // Game successfully completed alert
            let alertView = UIAlertView()
            alertView.addButtonWithTitle("New Game")
            alertView.title = "SUCCESS!"
            alertView.message = "You've finished the game B-)"
            alertView.show()
            alertView.delegate = self
            
            if VERBOSE {
                print("Game Successfully completed since the user has marked all the mines correctly without marking other squares")
            }
        }
    }
    
    // AlertView
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int) {
        if VERBOSE {
            print("Function : alertView\tClass : ViewController")
        }
        
        //start new game when the alert is dismissed
        self.resetBoard()
    }
}
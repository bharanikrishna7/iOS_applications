//
//  View.swift
//  DragMeToHellSwift
//
//  Created by Venkata Chekuri on 2/11/16.
//  Copyright © 2016 Venkata Chekuri. All rights reserved.
//

/** BUGS:
  * - This code might fail to work when we want the number of obstacles to be large
  *   This is because the possible position of other obstacles are eveluated using 
  *   the obstacle cells (which previously satisfied the condition) in this list. If
  *   these previous obstacles are placed unfavourably then it'll be impossible to find
  *   a cell which satisfies the condition.
  *  
  *   But since this does not impact the current application requirements so it should
  *   not cause an issue. Just a heads-up for someone who wants to reuse this code.
 */

import UIKit

class MyView: UIView {

    var dw : CGFloat = 0;  var dh : CGFloat = 0     // width and height of cell
    var x : CGFloat = 0;   var y : CGFloat = 0      // touch point coordinates
    var row : Int = 0;     var col : Int = 0        // selected cell in cell grid
    var inMotion : Bool = false                     // true if in process of dragging
    // this list will contain the cells where the obstacles will be placed
    var obstacleList = [Int]()
    // This will contain the information regarding which image will be chosen among obstacles list
    var obstacleImg = [Int]()
    // This will make sure that the cells are not being picked randomly again and again when drawRect
    // is called. Since for every touch operation made we have drawRect being called
    var listCreated : Bool = false
    // List containing the obstacles images which are present in Assets
    var obstacles : [String] = ["jaguar", "dragon", "aligator", "bomb", "fire"]
    
    override init(frame: CGRect) {
        print( "init(frame)" )
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        print( "init(coder)" )
        super.init(coder: aDecoder)
    }
    
    override func drawRect(rect: CGRect) {
        print( "drawRect:" )
        
        let context = UIGraphicsGetCurrentContext()!                            // obtain graphics context
        let bounds = self.bounds                                                // get view's location and size
        let w = CGRectGetWidth( bounds )                                        // w = width of view (in points)
        let h = CGRectGetHeight( bounds )                                       // h = height of view (in points)
        self.dw = w/10.0                                                        // dw = width of cell (in points)
        self.dh = h/10.0                                                        // dh = height of cell (in points)
        
        print( "view (width,height) = (\(w),\(h))" )
        print( "cell (width,height) = (\(self.dw),\(self.dh))" )
        
        // draw lines to form a 10x10 cell grid
        CGContextBeginPath( context )                                           // begin collecting drawing operations
        for i in 1..<10 {
            // draw horizontal grid line
            let iF = CGFloat(i)
            CGContextMoveToPoint( context, 0, iF*(self.dh))
            CGContextAddLineToPoint( context, w, iF*self.dh)
        }
        for i in 1..<10 {
            // draw vertical grid line
            let iFlt = CGFloat(i)
            CGContextMoveToPoint( context, iFlt*self.dw, 0 )
            CGContextAddLineToPoint( context, iFlt*self.dw, h )
        }
        UIColor.grayColor().setStroke()                                         // use gray as stroke color
        CGContextDrawPath( context, CGPathDrawingMode.Stroke )                  // execute collected drawing ops
        
        // establish bounding box for image
        var tl = self.inMotion ? CGPointMake( self.x, self.y )
            : CGPointMake( CGFloat(row)*self.dw, CGFloat(col)*self.dh )
        
        
        // Runs only once. Kind of like initializer but is used for getting random values
        if(!listCreated)
        {
            // random the TL value so that first cell has a random placement fo angel
            let initLoc = Int(arc4random_uniform(10))
            tl = CGPointMake(CGFloat(initLoc)*self.dw, tl.y)
            row = initLoc;          col = 0;
            x = CGFloat(initLoc)*self.dw;   y = 0;
            
            // now randomly generate the cells which can contain obstacles
            obstaclesLocate(initLoc)
        }
        
        // Draw the Image on the grid
        let imageRect = CGRectMake(tl.x, tl.y, self.dw, self.dh)
        
        // Draw the obstacle images in the cells from the list obstacleList[]
        // The grid location are obtained from obstacleList
        for counter in 0 ..< 25 {
            let x, y : Int
            x = obstacleList[counter] % 10
            y = obstacleList[counter] / 10
            UIImage(named: obstacles[obstacleImg[counter]])?.drawInRect(CGRectMake(CGFloat(x)*self.dw, CGFloat(y)*self.dh, self.dw, self.dh))
        }
        
        // place appropriate image where dragging stopped
        let img : UIImage?
        if (obstacleList.contains(self.row + self.col*10)) {
            img = UIImage(named:"devil")
        } else if (self.col == 9){
            img = UIImage(named:"angelF")
        } else
        {
            img = UIImage(named:"angel")
        }
        img!.drawInRect(imageRect)
    }
    
    
    /* Generate a list with cells which should contain random figures
     * and what random figure should appear in each of these cells
    */
    func obstaclesLocate(initLoc : Int) -> Void {
        // declare 100 cells since our app has 100 cells
        var cells = [Int]()
        
        // set all the elements in array to be 0. Since we will perform
        // a check later where chosen/occupied cell will be given values = 1
        var loop : Int = 0
        for i in 0..<100 {
            cells.append(0)
        }
        
        // Reserved cells are being changed to value 1 since we dont want the
        // random images to be put in these cells
        cells[initLoc] = 1
        //cells[99] = 1
            
        var x,y : Int
        
        // Randomly chose cells from the 100 cells to evaluate if we can insert
        // random image into it.
        while loop < 25 {
            let rand = Int(arc4random_uniform(99))
            // Print the random cell which has been chosen
            print("\nRAND = \(rand)")
                
            x = rand % 10
            y = rand / 10
        
            /** RULES FOR RANDOMLY PLACING OBSTACLES IN CELLS //
              * These rules feel little overkill but it'll help in getting almost all the patterns
              * possible with a free path
            **/
            
            /* These rules are for the cells which are not at the edges and corners of the cell grid
             *
             * These cells should have -
             * - Less than 2 grids among the upper left, upper right and upper can be occupied
             * - Less than 2 grids among the bottom left, bottom right and bottom can be occupied
             * - Less than 2 grids among the right, top right and bottom right can be occupied
             * - Less than 2 grids among the left, top left and bottom left can be occupied
             * 
             * This might look ineffective but since the grid size is less and it is just a simple 
             * number check so it'll really not take much time compared to other operations and the
             * difference will appear to be very less.
            */
            if(x != 0 && x != 9 && cells[rand] != 1)
            {
                if(y != 0 && y != 9)
                {
                    if(cells[(y-1)*10 + x] + cells[(y-1)*10 + (x+1)] + cells[(y-1)*10 + (x-1)] < 2)
                    {
                        if(cells[(y+1)*10 + x] + cells[(y+1)*10 + (x+1)] + cells[(y-1)*10 + (x+1)] < 2)
                        {
                            if(cells[y*10 + (x+1)] + cells[(y-1)*10 + (x+1)] + cells[(y+1)*10 + (x+1)] < 2)
                            {
                                if(cells[y*10 + (x-1)] + cells[(y-1)*10 + (x-1)] + cells[(y+1)*10 + (x-1)] < 2)
                                {
                                    if(cells[y*10 + (x-1)] + cells[y*10 + (x+1)] < 2)
                                    {
                                        if(cells[(y+1)*10 + x] + cells[(y-1)*10 + x] < 2)
                                        {
                                            cells[rand] = 1
                                            obstacleList.append(rand)
                                            loop++
                                            obstacleImg.append(Int(arc4random_uniform(5)))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
           /* These rules are for the cells which are on the left edge of the cell grid
            *
            * These cells should have -
            * - Less than 2 grids among the right, top right and bottom right cells can be occupied
            * - Less than 2 grids among the top and bottom cells can be occupied
            */
            if(x == 0 && y != 0 && y != 9 && cells[rand] != 1)
            {
                if(cells[(y-1)*10] + cells[(y+1)*10] < 2)
                {
                    if(cells[(y)*10 + 1] + cells[(y+1)*10 + 1] + cells[(y-1) + 1] < 2)
                    {
                        cells[rand] = 1
                        obstacleList.append(rand)
                        obstacleImg.append(Int(arc4random_uniform(5)))
                        loop++
                    }
                }
            }

            /* These rules are for the cells which are on the top edge of the cell grid
            *
            * These cells should have -
            * - Less than 2 grids among the bottom right, bottom left and bottom cells can be occupied
            * - Less than 2 grids among the left and right cells can be occupied
            */
            if(y == 0 && x != 0 && x != 9 && cells[rand] != 1)
            {
                if(cells[x-1] + cells[x+1] < 2)
                {
                    if(cells[10 + x] + cells[10 + (x-1)] + cells[10 + (x+1)] < 2)
                    {
                        cells[rand] = 1
                        obstacleList.append(rand)
                        obstacleImg.append(Int(arc4random_uniform(5)))
                        loop++
                    }
                }
            }
            
            /* These rules are for the cells which are on the right edge of the cell grid
            *
            * These cells should have -
            * - Less than 2 grids among the left, top left and bottom left cells can be occupied
            * - Less than 2 grids among the top and bottom cells can be occupied
            */
            if(x == 9 && y != 9 && y != 0 && cells[rand] != 1)
            {
                if(cells[(y-1)*10 + x] + cells[(y+1)*10 + x] < 2)
                {
                    if(cells[y*10 + (x-1)] + cells[(y-1)*10 + (x-1)] + cells[(y+1)*10 + (x-1)] < 2)
                    {
                        cells[rand] = 1
                        obstacleList.append(rand)
                        obstacleImg.append(Int(arc4random_uniform(5)))
                        loop++
                    }
                }
            }
            
            /* These rules are for the cells which are on the bottom edge of the cell grid
            *
            * These cells should have -
            * - Less than 2 grids among the top right, top left and top cells can be occupied
            * - Less than 2 grids among the left and right cells can be occupied
            */
            if(y == 9 && x != 9 && x != 0 && cells[rand] != 1)
            {
                if(cells[y*10 + (x-1)] + cells[y*10 + (x+1)] < 2)
                {
                    if(cells[(y-1)*10 + x] + cells[(y-1)*10 + (x-1)] + cells[(y-1)*10 + (x+1)] < 2)
                    {
                        cells[rand] = 1
                        obstacleList.append(rand)
                        obstacleImg.append(Int(arc4random_uniform(5)))
                        loop++
                    }
                }
            }
        }
        
        // Debugging : Print the cells which have been randomly picked and number of cells which have been picked (this must be 25)
        print("\nOBSTACLELIST COUNT = \(obstacleList.count)\n")
        for i in 0..<25 {
            print("\(obstacleList[i]) \t")
        }
        
        // Setting listCreated to true will disable this function being called again and again
        // Effective to check this condition in drawRect() before calling obstaclesLocate()
        listCreated = true;
    }
    
    // Touches began function
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchRow, touchCol : Int
        var xy : CGPoint
        
        print( "touchesBegan:withEvent:" )
        super.touchesBegan(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            self.inMotion = (self.row == touchRow  &&  self.col == touchCol)
            print( "touch point (x,y) = (\(self.x),\(self.y))" )
            print( "  falls in cell (\(touchRow),\(touchCol))" )
        }
    }
    
    // Touches moved function
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        var touchRow, touchCol : Int
        var xy : CGPoint
        
        print( "touchesMoved:withEvent:" )
        super.touchesMoved(touches, withEvent: event)
        for t in touches {
            xy = t.locationInView(self)
            self.x = xy.x;  self.y = xy.y
            touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
            print( "touch point (x,y) = (\(self.x),\(self.y))" )
            print( "  falls in cell (\(touchRow),\(touchCol))" )
            
            // Autoupdate the B/G color when touches moved occurs
            self.row = touchRow;  self.col = touchCol
            if (obstacleList.contains(self.row + self.col*10)) {
                self.backgroundColor = UIColor(red: (255/255.0), green: (70/255.0), blue: (70/255.0), alpha: 1.0)           // When overlaps with obstacle (Red Color)
            } else if(self.col == 9){
                self.backgroundColor = UIColor(red: (180/255.0), green: (60/255.0), blue: (200/255.0), alpha: 0.999)        // When in the last row (Purple Color)
            } else
            {
                self.backgroundColor = UIColor(red: (200/255.0), green: (200/255.0), blue: (200/255.0), alpha: 0.999)       // When not in any of the above (Grey Color)
            }
        }
        
        if self.inMotion {
            self.setNeedsDisplay()   // request view re-draw
        }
    }
    
    // Touched ended function
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print( "touchesEnded:withEvent:" )
        super.touchesEnded(touches, withEvent: event)
        if self.inMotion {
            var touchRow : Int = 0;  var touchCol : Int = 0
            var xy : CGPoint
            
            for t in touches {
                xy = t.locationInView(self)
                self.x = xy.x;  self.y = xy.y
                touchRow = Int(self.x / self.dw);  touchCol = Int(self.y / self.dh)
                print( "touch point (x,y) = (\(self.x),\(self.y))" )
                print( "  falls in cell (\(touchRow),\(touchCol))" )
            }
            self.inMotion = false
            self.row = touchRow;  self.col = touchCol
            
            // Update B/G color depending on the current touch location
            if (obstacleList.contains(self.row + self.col*10)) {
                self.backgroundColor = UIColor(red: (255/255.0), green: (70/255.0), blue: (70/255.0), alpha: 1.0)           // When overlaps with obstacle (Red Color)
            } else if(self.col == 9){
                self.backgroundColor = UIColor(red: (180/255.0), green: (60/255.0), blue: (200/255.0), alpha: 0.999)        // When in the last row (Purple Color)
            } else
            {
                self.backgroundColor = UIColor(red: (200/255.0), green: (200/255.0), blue: (200/255.0), alpha: 0.999)       // When not in any of the above (Grey Color)
            }
            self.setNeedsDisplay()
        }
    }
    
    
//    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        print( "touchesCancelled:withEvent:" )
//        super.touchesCancelled(touches, withEvent: event)
//    }

}

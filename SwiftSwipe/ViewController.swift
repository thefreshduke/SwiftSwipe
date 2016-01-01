//
//  ViewController.swift
//  SwiftSwipe
//
//  Created by Scotty Shaw on 12/29/15.
//  Copyright © 2015 ___sks6___. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let deviceSize: CGSize = UIScreen.mainScreen().bounds.size
    let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
    let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
    
    let midpointX: CGFloat = UIScreen.mainScreen().bounds.size.width / 2
    let midpointY: CGFloat = UIScreen.mainScreen().bounds.size.height / 2
    let midpoint: CGPoint = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: UIScreen.mainScreen().bounds.size.height / 2)
    
    @IBOutlet weak var image: UIImageView!
    
    var imageWidth: CGFloat = 0.0
    var imageHeight: CGFloat = 0.0
    
    var xOffset: CGFloat = 0.0
    var yOffset: CGFloat = 0.0
    
//    var lastTouch : UITouch!
    var originX: CGFloat!
    var originY: CGFloat!
    
    var isTouchValid: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        imageWidth = image.frame.width
        imageHeight = image.frame.height
        
        originX = (deviceWidth - imageWidth) / 2
        originY = (deviceHeight - imageHeight) / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let startX = touch!.locationInView(self.view).x
        let startY = touch!.locationInView(self.view).y
        let touchPoint = CGPoint(x: startX, y: startY)
        
        let distanceOfTouchFromMidpoint = calculateDistanceFrom(midpoint, to: touchPoint)
        
        if (distanceOfTouchFromMidpoint <= imageWidth / 3) {
            isTouchValid = true
            self.view.backgroundColor = UIColor.greenColor()
            super.touchesBegan(touches, withEvent: event)
        }
        else {
            self.view.backgroundColor = UIColor.redColor()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let endX = touch!.locationInView(self.view).x
        let endY = touch!.locationInView(self.view).y
        
        print("------------\(endX), \(endY)------------")
        print("")
        
        // instead of snapping back to midpoint, calculate velocity and send bubble off-screen
        image.frame = CGRect(x: originX, y: originY, width: imageWidth, height: imageHeight)
        
        if (isTouchValid) {
            let successViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SuccessViewController") as! SuccessViewController
            self.presentViewController(successViewController, animated: true, completion: nil)
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        isTouchValid = false
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (isTouchValid) {
            let touch = touches.first
            let movingX = touch!.locationInView(self.view).x
            let movingY = touch!.locationInView(self.view).y
            
            print("\(movingX), \(movingY)")
            
            //        lastTouch = touch
            
            let newX = movingX - xOffset - imageWidth / 2
            let newY = movingY - yOffset - imageHeight / 2
            
            image.frame = CGRect(x: newX, y: newY, width: imageWidth, height: imageHeight)
            
            super.touchesMoved(touches, withEvent: event)
        }
    }
    
    func calculateDistanceFrom(point1: CGPoint, to point2: CGPoint) -> CGFloat {
        xOffset = point2.x - point1.x
        yOffset = point2.y - point1.y
        
        let xDifferenceSquared = pow(xOffset, CGFloat(2))
        let yDifferenceSquared = pow(yOffset, CGFloat(2))
        
        return sqrt(xDifferenceSquared + yDifferenceSquared)
    }
}

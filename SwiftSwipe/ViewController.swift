//
//  ViewController.swift
//  SwiftSwipe
//
//  Created by Scotty Shaw on 12/29/15.
//  Copyright © 2015 ___sks6___. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let deviceSize: CGSize = UIScreen.mainScreen().bounds.size
    let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
    let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
    
    let midpoint: CGPoint = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: UIScreen.mainScreen().bounds.size.height / 2)
    
    @IBOutlet weak var image: UIImageView!
    
    var locationManager: CLLocationManager!
    
    var imageWidth: CGFloat = 0.0
    var imageHeight: CGFloat = 0.0
    
    var xTouchOffset: CGFloat = 0.0
    var yTouchOffset: CGFloat = 0.0
    
    var maximumAllowedOffset: CGFloat = 0.0
    var bubbleReleaseBorderRadius: CGFloat = 0.0
    
    var lastMovingTouch: UITouch!
    var originX: CGFloat!
    var originY: CGFloat!
    
    var isTouchValid: Bool = false
    
//    var startTime = NSTimeInterval()
//    var timer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.headingFilter = kCLHeadingFilterNone
        locationManager.startUpdatingHeading()
        
        imageWidth = image.frame.width
        imageHeight = image.frame.height
        
        maximumAllowedOffset = imageWidth / 3
        
        bubbleReleaseBorderRadius = imageWidth
        
        originX = (deviceWidth - imageWidth) / 2
        originY = (deviceHeight - imageHeight) / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    *
    * TOUCH AND INTERACTION
    *
    **/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let startX = touch!.locationInView(self.view).x
        let startY = touch!.locationInView(self.view).y
        let touchPoint = CGPoint(x: startX, y: startY)
        
        (xTouchOffset, yTouchOffset) = calculateScalarDistancesFrom(midpoint, to: touchPoint)
        let distanceOfTouchFromMidpoint = calculateVectorDistanceUsing(xTouchOffset, and: yTouchOffset)
        
        if (distanceOfTouchFromMidpoint <= maximumAllowedOffset) {
            isTouchValid = true
            self.view.backgroundColor = UIColor.greenColor()
            super.touchesBegan(touches, withEvent: event)
        }
        else {
            self.view.backgroundColor = UIColor.redColor()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
//        for touch in touches {
//            print("\(touch.locationInView(self.view))")
//        }
        
        if (isTouchValid) {
            lastMovingTouch = touches.first
            
            let touch = touches.first
            let movingX = touch!.locationInView(self.view).x
            let movingY = touch!.locationInView(self.view).y
            
            let newX = movingX - xTouchOffset - imageWidth / 2
            let newY = movingY - yTouchOffset - imageHeight / 2
            
            image.frame = CGRect(x: newX, y: newY, width: imageWidth, height: imageHeight)
            
            super.touchesMoved(touches, withEvent: event)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
//        print("---------------------")
        
        let touch = touches.first
        
        if (isTouchValid) {
            let lastTouch = touches.first
            
            let endX = touch!.locationInView(self.view).x
            let endY = touch!.locationInView(self.view).y
            let bubbleEndPosition = CGPoint(x: endX + xTouchOffset, y: endY + yTouchOffset)
            let bubbleVectorDistanceMoved = calculateVectorDistanceFrom(midpoint, to: bubbleEndPosition)
            
//            print(bubbleVectorDistanceMoved)
//            print(bubbleReleaseBorderRadius)
            
            if (bubbleVectorDistanceMoved >= bubbleReleaseBorderRadius) {
                
                // calculate velocity and send bubble off-screen
                
                let successViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SuccessViewController") as! SuccessViewController
                self.presentViewController(successViewController, animated: true, completion: nil)
            }
            else {
                image.frame = CGRect(x: originX, y: originY, width: imageWidth, height: imageHeight)
            }
        }
        
        // reset to pre-touch conditions
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        isTouchValid = false
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    /**
    * 
    * GEOMETRY AND PHYSICS CALCULATIONS
    *
    **/
    
    private func calculateScalarDistancesFrom(point1: CGPoint, to point2: CGPoint) -> (CGFloat, CGFloat) {
        let xDistance = point2.x - point1.x
        let yDistance = point2.y - point1.y
        
        return (xDistance, yDistance)
    }
    
    private func calculateVectorDistanceUsing(scalar1: CGFloat, and scalar2: CGFloat) -> CGFloat {
        let aSquared = pow(scalar1, CGFloat(2))
        let bSquared = pow(scalar2, CGFloat(2))
        
        return sqrt(aSquared + bSquared)
    }
    
    private func calculateVectorDistanceFrom(point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let (xDistance, yDistance) = calculateScalarDistancesFrom(point1, to: point2)
        let vectorDistance = calculateVectorDistanceUsing(xDistance, and: yDistance)
        
        return vectorDistance
    }
    
    func calculateBubbleVelocity(point1: CGPoint, to point2: CGPoint) -> (CGFloat, CGFloat) {
        print("bubble")
        return calculateScalarDistancesFrom(point1, to: point2)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("Mag Heading: \(newHeading.magneticHeading)")
        print("True Heading: \(newHeading.trueHeading)")
    }
}

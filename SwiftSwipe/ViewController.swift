//
//  ViewController.swift
//  SwiftSwipe
//
//  Created by Scotty Shaw on 12/29/15.
//  Copyright © 2015 ___sks6___. All rights reserved.
//

import UIKit
import CoreLocation
import Darwin

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let deviceSize: CGSize = UIScreen.mainScreen().bounds.size
    let deviceWidth: CGFloat = UIScreen.mainScreen().bounds.size.width
    let deviceHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
    
    let midpoint: CGPoint = CGPoint(x: UIScreen.mainScreen().bounds.size.width / 2, y: UIScreen.mainScreen().bounds.size.height / 2)
    
    let π: Double! = M_PI
    
    @IBOutlet weak var image: UIImageView!
    
    var locationManager: CLLocationManager!
    
    var imageWidth: CGFloat = 0.0
    var imageHeight: CGFloat = 0.0
    
    var xTouchOffset: CGFloat = 0.0
    var yTouchOffset: CGFloat = 0.0
    
    var maximumAllowedOffset: CGFloat = 0.0
    var bubbleReleaseBorderRadius: CGFloat = 0.0
    
    var lastMovingTouchLocation: CGPoint!
    var originX: CGFloat!
    var originY: CGFloat!
    
    var isTouchValid: Bool = false
    
    var bubbleXVelocity: CGFloat! = 0.0
    var bubbleYVelocity: CGFloat! = 0.0
    
    var trueNorth: CLLocationDirection!
    var geographicBubbleSwipeHeading: CLLocationDirection!
    
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
            self.view.backgroundColor = UIColor.whiteColor()
            super.touchesBegan(touches, withEvent: event)
        }
        else {
            self.view.backgroundColor = UIColor.redColor()
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        
        if (isTouchValid) {
            let currentX = touch!.locationInView(self.view).x - xTouchOffset
            let currentY = touch!.locationInView(self.view).y - yTouchOffset
            let bubbleMovingPosition = CGPoint(x: currentX, y: currentY)
            
            lastMovingTouchLocation = bubbleMovingPosition
            
            let bubbleVectorDistanceMoved = calculateVectorDistanceFrom(midpoint, to: bubbleMovingPosition)
            
            if (bubbleVectorDistanceMoved >= bubbleReleaseBorderRadius) {
                self.view.backgroundColor = UIColor.greenColor()
            }
            else {
                self.view.backgroundColor = UIColor.whiteColor()
            }
            
            let newImageX = currentX - imageWidth / 2
            let newImageY = currentY - imageHeight / 2
            
            image.frame = CGRect(x: newImageX, y: newImageY, width: imageWidth, height: imageHeight)
            
            super.touchesMoved(touches, withEvent: event)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        let touch = touches.first
        
        if (isTouchValid) {
            let finalTouch = touches.first
            
            let endX = touch!.locationInView(self.view).x - xTouchOffset
            let endY = touch!.locationInView(self.view).y - yTouchOffset
            let bubbleEndPosition = CGPoint(x: endX, y: endY)
            let bubbleVectorDistanceMoved = calculateVectorDistanceFrom(midpoint, to: bubbleEndPosition)
            
            let finalTouchPoint = finalTouch?.locationInView(self.view)
            
            if (lastMovingTouchLocation != nil) {
                let (xVelocity, yVelocity) = calculateScalarDistancesFrom(lastMovingTouchLocation, to: finalTouchPoint!)
                
                (bubbleXVelocity, bubbleYVelocity) = (xVelocity, yVelocity)
                
                let bubbleVelocity = calculateVectorDistanceUsing(xVelocity, and: yVelocity)
                
                if (bubbleVectorDistanceMoved >= bubbleReleaseBorderRadius && bubbleVelocity > 0) {
                    
                    var bubblePosition = CGPoint(x: 0.0, y: 0.0)
                    
                    bubblePosition = image.frame.origin
                    
                    moveBubble(bubblePosition, withScalarVelocities: xVelocity, and: yVelocity)
                    
//                    let bubbleSwipeHeadingRadians = CLLocationDirection(atan(bubbleXVelocity / bubbleYVelocity))
                    
                    let opposite = midpoint.y - finalTouchPoint!.y
                    let adjacent = finalTouchPoint!.x - midpoint.x
                    
                    var relativeBubbleSwipeHeading: CLLocationDirection!
                    
                    if (adjacent == 0.0) {
                        if (opposite == 1.0) {
                            relativeBubbleSwipeHeading = 0.0
                        }
                        else {
                            relativeBubbleSwipeHeading = 180.0
                        }
                    }
                    else {
                        let bubbleSwipeHeadingRadians = CLLocationDirection(atan(opposite / adjacent))
                        relativeBubbleSwipeHeading = 90 + 180 * bubbleSwipeHeadingRadians / π
                        if (adjacent > 0.0) {
                            relativeBubbleSwipeHeading = relativeBubbleSwipeHeading + CLLocationDirection(180.0)
                        }
                    }
                    
                    geographicBubbleSwipeHeading = (360 + trueNorth - relativeBubbleSwipeHeading) % 360
                    
                    let successViewController = self.storyboard!.instantiateViewControllerWithIdentifier("SuccessViewController") as! SuccessViewController
                    self.presentViewController(successViewController, animated: true, completion: {
                        self.view.backgroundColor = UIColor.whiteColor()
                    })
                }
                else {
                    image.frame = CGRect(x: originX, y: originY, width: imageWidth, height: imageHeight)
                    self.view.backgroundColor = UIColor.whiteColor()
                }
            }
        }
        else {
            self.view.backgroundColor = UIColor.whiteColor()
        }
        
        // reset to pre-touch conditions
        
        isTouchValid = false
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    private func moveBubble(currentBubblePosition: CGPoint, withScalarVelocities xVelocity: CGFloat, and yVelocity: CGFloat) {
        let imageCenterPositionX = currentBubblePosition.x + imageWidth
        let imageCenterPositionY = currentBubblePosition.y + imageHeight
        let imageCenterPosition = CGPoint(x: imageCenterPositionX, y: imageCenterPositionY)
        
        var newBubblePosition = CGPoint(x: 0.0, y: 0.0)
        var bubbleDistanceFromMidpoint: CGFloat = 0.0
        
        bubbleDistanceFromMidpoint = calculateVectorDistanceFrom(midpoint, to: imageCenterPosition)
        
        if (bubbleDistanceFromMidpoint < deviceHeight) {
            
            let newBubblePositionX = currentBubblePosition.x + xVelocity
            let newBubblePositionY = currentBubblePosition.y + yVelocity
            
            image.frame = CGRect(x: newBubblePositionX, y: newBubblePositionY, width: imageWidth, height: imageHeight)
            
            newBubblePosition = CGPoint(x: newBubblePositionX, y: newBubblePositionY)
        }
        else {
            return
        }
        
        moveBubble(newBubblePosition, withScalarVelocities: xVelocity, and: yVelocity)
    }
    
    /**
    *
    * TRIGONOMETRY AND PHYSICS CALCULATIONS
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
    
    private func calculateBubbleVelocity(point1: CGPoint, to point2: CGPoint) -> (CGFloat, CGFloat) {
        return calculateScalarDistancesFrom(point1, to: point2)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        trueNorth = newHeading.trueHeading
        geographicBubbleSwipeHeading = CLLocationDirection (atan(bubbleXVelocity / bubbleYVelocity))
    }
    
    /**
     *
     * GETTERS
     *
     **/
    
    func getBubbleXVelocityAndBubbleYVelocity() -> (CGFloat, CGFloat) {
        return (bubbleXVelocity, bubbleYVelocity)
    }
    
    func getBubbleDirection() -> CLLocationDirection {
        return geographicBubbleSwipeHeading
    }
}

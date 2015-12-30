//
//  ViewController.swift
//  SwiftSwipe
//
//  Created by Scotty Shaw on 12/29/15.
//  Copyright © 2015 ___sks6___. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    var imageWidth : CGFloat = 0.0
    var imageHeight : CGFloat = 0.0
    
//    var lastTouch : UITouch!
    var originX : CGFloat!
    var originY : CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let deviceSize = UIScreen.mainScreen().bounds.size
        let deviceWidth = deviceSize.width
        let deviceHeight = deviceSize.height
        
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
        
        print("------------\(startX), \(startY)------------")
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let endX = touch!.locationInView(self.view).x
        let endY = touch!.locationInView(self.view).y
        
        print("------------\(endX), \(endY)------------")
        
        image.frame = CGRect(x: originX, y: originY, width: imageWidth, height: imageHeight)
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let movingX = touch!.locationInView(self.view).x
        let movingY = touch!.locationInView(self.view).y
        
        print("\(movingX), \(movingY)")
        
//        lastTouch = touch
        
        let newX = movingX - imageWidth / 2
        let newY = movingY - imageHeight / 2
        
        image.frame = CGRect(x: newX, y: newY, width: imageWidth, height: imageHeight)
        
        super.touchesMoved(touches, withEvent: event)
    }
}


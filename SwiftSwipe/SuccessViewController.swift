//
//  SuccessViewController.swift
//  SwiftSwipe
//
//  Created by Scotty Shaw on 12/30/15.
//  Copyright © 2015 ___sks6___. All rights reserved.
//

import UIKit

class SuccessViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loadBubbleViewController(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

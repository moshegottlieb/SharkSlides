//
//  SlideshowPreferencesViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 18/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class SlideshowPreferencesViewController: NSViewController,NSTextFieldDelegate {
    let transitions = ["Fade","None"]
    override func viewDidLoad() {
        super.viewDidLoad()
        updateEnabled(self)
    }
    
    @IBOutlet weak var durationStepper: NSStepper!
    @IBAction func updateEnabled(sender: AnyObject) {
        let val : String? = NSUserDefaults.standardUserDefaults().stringForKey("transition")
        if val == "None"{
            durationStepper.enabled = false
        } else {
            durationStepper.enabled = true
        }
    }
    
}

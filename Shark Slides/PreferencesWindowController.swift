//
//  PreferencesWindowController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 18/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        self.performSelector(Selector("setup"), withObject: nil, afterDelay: 0)
    }
    @objc func setup(){
        self.window?.toolbar?.selectedItemIdentifier = self.window?.toolbar?.items.first?.itemIdentifier
        slideshow(self)
    }
    
    @IBAction func slideshow(sender: AnyObject) {
        self.contentViewController?.performSegueWithIdentifier("Slideshow", sender: sender)
    }
    @IBAction func video(sender: AnyObject) {
        self.contentViewController?.performSegueWithIdentifier("Video", sender: sender)
    }
    @IBAction func about(sender: AnyObject) {
        
    }
}

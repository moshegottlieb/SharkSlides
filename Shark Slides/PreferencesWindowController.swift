//
//  PreferencesWindowController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 18/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController,About {

    @IBOutlet weak var infoButton: NSButton!
    
    override var window : NSWindow?{
        didSet{
            if window != nil {
                performSelector(Selector("setup"), withObject: nil, afterDelay: 0, inModes: [NSRunLoopCommonModes])
            }
        }
    }
    
    @objc func setup(){
        self.window?.toolbar?.selectedItemIdentifier = self.window?.toolbar?.items.first?.itemIdentifier
        slideshow(self)
    }
    
    @IBAction func slideshow(sender: AnyObject) {
        contentViewController?.performSegueWithIdentifier("Slideshow", sender: sender)
    }
    @IBAction func video(sender: AnyObject) {
        contentViewController?.performSegueWithIdentifier("Video", sender: sender)
    }
    func about(){
        infoButton.target?.performSelector(infoButton.action, withObject: self)
    }
}

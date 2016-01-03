//
//  ShowContentViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 03/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa
import AVFoundation


class ShowContentViewController: NSViewController {
    var url: NSURL! = nil
    
    static func contentController(url:NSURL!, storyBoard:NSStoryboard!) -> ShowContentViewController?{
        var type: AnyObject?
        do {
            try url.getResourceValue(&type, forKey: NSURLTypeIdentifierKey)
            if let type = type as? String {
                if UTTypeConformsTo(type, kUTTypeImage as String){
                    let content = storyBoard.instantiateControllerWithIdentifier("ShowImageContentViewController") as! ShowContentViewController
                    if content.loadContent(url){
                        return content;
                    } else {
                        return nil
                    }
                }
            }
            
        } catch {
            // nothing
        }
        return nil
    }
    
    func loadContent(url: NSURL!) -> Bool{
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer?.backgroundColor = NSColor.clearColor().CGColor
        // Do view setup here.
    }
    
}


class ScaledImageView : NSView{
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer?.backgroundColor = NSColor.clearColor().CGColor
    }
    var image : NSImage? {
        didSet{
            setNeedsDisplayInRect(self.bounds)
        }
    }
    override func drawRect(dirtyRect: NSRect) {
        if let image = self.image{
            let imgRect = AVMakeRectWithAspectRatioInsideRect(image.size, self.bounds)
            image.drawInRect(imgRect)
        }
    }
}

class KeyCaptureView : NSImageView {
    @IBOutlet weak var viewController:NSViewController!{
        didSet{
            let controllerNextResponder:NSResponder? = viewController.nextResponder
            super.nextResponder = controllerNextResponder
            viewController.nextResponder = nil
            let ownNextResponder : NSResponder? = nextResponder
            super.nextResponder = viewController
            viewController.nextResponder = ownNextResponder
        }
    }
    override var nextResponder:NSResponder?{
        didSet{
            
        }
    }
    override var acceptsFirstResponder : Bool{
        return true
    }
}

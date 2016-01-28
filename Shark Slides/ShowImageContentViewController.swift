//
//  ShowImageContentViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 03/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa
import AVFoundation


class ShowImageContentViewController: ShowContentViewController {

    @IBOutlet weak var imageView: ScaledImageView!
    private var image : NSImage?
    
    override func loadContent(url: NSURL!) -> Bool {
        image = NSImage(contentsOfURL: url)
        if image != nil{
            return true
        }
        return false
    }
    
    override class func isSupported(uti:String) -> Bool{
        return UTTypeConformsTo(uti, kUTTypeImage as String)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        didPlay(true)
        success = true
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


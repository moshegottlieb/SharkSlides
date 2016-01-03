//
//  ShowImageContentViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 03/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image
    }
    
}

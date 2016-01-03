//
//  ViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 25/11/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Cocoa
import MediaLibrary


class LoadingController: NSViewController {
    
    @IBOutlet weak var progress: NSProgressIndicator!
    
    let mediaLibrary : MediaLibrary = MediaLibrary()
    var completion : (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.startAnimation(nil)
    }
    
    override func viewWillAppear() {
        view.window?.styleMask = NSBorderlessWindowMask
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        mediaLibrary.load { () -> () in
            self.dismissViewController(self)
            if let completion = self.completion{
                completion()
            }
        }
    }

}


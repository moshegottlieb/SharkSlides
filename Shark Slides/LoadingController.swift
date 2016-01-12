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
    
    @IBOutlet weak var message: NSTextField!
    @IBOutlet weak var progress: NSProgressIndicator!
    
    var completion : (() -> ())?
    
    func setMessageText(text:String!){
        message.cell?.stringValue = text
        message.hidden = (text as NSString).length == 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        message.hidden = true
        progress.startAnimation(nil)
    }
    
    override func viewWillAppear() {
        view.window?.styleMask = NSBorderlessWindowMask
        super.viewWillAppear()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if let completion = completion{
            completion()
        }
    }

}


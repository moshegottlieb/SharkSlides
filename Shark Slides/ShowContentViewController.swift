//
//  ShowContentViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 03/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class ShowContentViewController: NSViewController {
    var success : Bool = false
    var url: NSURL! = nil
    
    var completion : ((shouldDelay:Bool) -> ())?
    var isPaused : Bool = false
    
    static func contentController(url:NSURL!, storyBoard:NSStoryboard!) -> ShowContentViewController?{
        var type: AnyObject?
        do {
            try url.getResourceValue(&type, forKey: NSURLTypeIdentifierKey)
            if let type = type as? String {
                var identifier : String?
                if ShowVideoContentViewController.isSupported(type){
                    identifier = "ShowVideoContentViewController"
                } else if ShowImageContentViewController.isSupported(type){
                    identifier = "ShowImageContentViewController"
                }
                if let identifier = identifier{
                    let content = storyBoard.instantiateControllerWithIdentifier(identifier) as! ShowContentViewController
                    content.url = url
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
    
    class func isSupported(uti:String) -> Bool{
        return ShowVideoContentViewController.isSupported(uti) || ShowImageContentViewController.isSupported(uti)
    }
    
    func isTimebased() -> Bool {
        return false
    }
    
    func pause(){
        isPaused = true
    }
    func resume(){
        isPaused = false
    }
    
    func loadContent(url: NSURL!) -> Bool{
        return false
    }
    
    func stop(){
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer?.backgroundColor = NSColor.clearColor().CGColor
        // Do view setup here.
    }
    
    func didPlay(shouldDelay:Bool){
        if let completion = self.completion{
            completion(shouldDelay: shouldDelay)
        }
    }
    
}


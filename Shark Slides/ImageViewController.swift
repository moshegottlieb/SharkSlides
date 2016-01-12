//
//  ImageViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 28/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Cocoa
import MediaLibrary



class ImageViewController: NSViewController, NSWindowDelegate {
    var index : Int = 0
    var playCount : Int = 0
    var cursor: NSCursor?
    var message : NSImageView?
    var isUserPaused : Bool = false {
        didSet {
            if isUserPaused{
                displayedController?.pause()
            } else {
                displayedController?.resume()
            }
        }
    }
    var pausedRef : UInt = 0
    var isPaused : Bool{
        get{
            return pausedRef > 0
        }
        set{
            if newValue{
                ++pausedRef
            } else {
                if pausedRef > 0{
                    --pausedRef
                }
            }
            if pausedRef == 0{
                autoAdvance = true
            } else if timer != nil{
                autoAdvance = false
            }
        }
    }
    var isContentPlaying : Bool = false
    
    
    var autoAdvance : Bool = false{
        didSet{
            if autoAdvance{
                timer?.start()
            } else{
                timer?.stop()
            }
        }
    }
    
    var objects : Array<NSURL>?
    var autoRepeat : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("repeat")
    }
    var completion : ((vc: NSViewController!) -> ())?
    var requestAccess : ((url:NSURL!)->())?
    var interval : NSTimeInterval {
        return NSUserDefaults.standardUserDefaults().doubleForKey("interval") + NSUserDefaults.standardUserDefaults().doubleForKey("transition.duration")
    }
    var shuffle : Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("shuffle")
    }
    var timer: Timer?
    var displayedController : ShowContentViewController?
    var messageTimer : Timer?
    
    @IBOutlet weak var captureWindow: KeyCaptureView!
    @IBOutlet weak var container: NSView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        timer = Timer(fire: { () -> () in
            self.playNext()
            }, autoRepeat: true, interval: interval)
    }
    
    private func finish(){
        isPaused = true
        if let completion = self.completion{
            completion(vc:self)
        }
    }
    
    @objc private func playNext(){
        if isContentPlaying{
            return
        }
        if let objects = objects{
            if objects.count == 0{
                finish()
                return
            }
            let url = objects[index]
            ++index
            if index == objects.count{
                if !autoRepeat || playCount == 0 {
                    finish()
                    return
                } else {
                    index = 0
                }
            }
            var didPlay : Bool = false
        
            url.startAccessingSecurityScopedResource()
            if (url.isSandboxed()){
                finish()
                if let requestAccess = self.requestAccess{
                    requestAccess(url: url)
                }
                url.stopAccessingSecurityScopedResource()
                return
            }
            let content = ShowContentViewController.contentController(url, storyBoard: storyboard)
            if ((content?.loadContent(url)) == true){
                didPlay = true
                ++playCount
                Transition.defaultTransition()?.transtionFrom(self.displayedController, toView: content, parent: self, completion: { () -> () in
                    
                })
                displayedController = content
                isPaused = true
                isContentPlaying = true
                content?.completion = { (shouldDelay:Bool) -> () in
                    self.isContentPlaying = false
                    self.isPaused = false
                    if !shouldDelay && !self.isPaused{
                        self.playNext()
                    }
                }
            }
            url.stopAccessingSecurityScopedResource()
            
            if !didPlay{
                dispatch_after(0, dispatch_get_main_queue(), {
                    self.playNext()
                })
            }
        }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.layer?.backgroundColor = NSColor.blackColor().CGColor
        view.window?.toggleFullScreen(nil)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.view.window?.close()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(captureWindow)
        if shuffle{
            objects?.shuffleInPlace()
        }
        self.container.hidden = false
        Timer(fire: { () -> () in
            self.playNext()
            }, autoRepeat: false, interval: 0.5).start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container.hidden = true
        self.container.layer?.backgroundColor = NSColor.clearColor().CGColor
        self.captureWindow.layer?.backgroundColor = NSColor.clearColor().CGColor
        let img = NSImage(size: NSSize(width: 1, height: 1))
        self.cursor = NSCursor(image: img, hotSpot: NSPoint(x: 0, y: 0))
    }
    
    override func cursorUpdate(event: NSEvent) {
        self.view.addCursorRect(self.view.bounds, cursor: cursor!)
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
    }
    
    func showMessage(message:String!){
        self.message?.removeFromSuperview()
        self.message = NSImageView()
        self.message?.translatesAutoresizingMaskIntoConstraints = false
        self.message?.cell?.image = NSImage(named: message)
        let views : [String: AnyObject] = ["message" : self.message!]
        self.view.addSubview(self.message!)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[message]-20-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.view.addConstraint(NSLayoutConstraint(item: self.message!, attribute:.CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0))
        self.message?.hidden = false
        self.message?.alphaValue = 0
        messageTimer?.stop()
        messageTimer = nil
        NSAnimationContext.runAnimationGroup({ (context : NSAnimationContext) -> Void in
            context.duration = 0.3
            self.message?.alphaValue = 1
            }, completionHandler: {
                self.messageTimer = Timer(fire: { () -> () in
                    NSAnimationContext.runAnimationGroup({ (context : NSAnimationContext) -> Void in
                        context.duration = 0.3
                        self.message?.alphaValue = 0
                        }, completionHandler:  {
                            self.message?.hidden = true
                            self.messageTimer?.stop()
                            self.messageTimer = nil
                    })
                    
                    }, autoRepeat: false, interval: 1)
                self.messageTimer?.start()
        })
        
    }
    
    override func keyDown(theEvent: NSEvent) {
        let unichar = (theEvent.characters! as NSString).characterAtIndex(0)
        switch unichar{
        case 27: // Escape
           finish()
        case 32: // Space
            if isUserPaused{
                isUserPaused = false
                isPaused = false
                showMessage("play")
            } else {
                isUserPaused = true
                isPaused = true
                showMessage("pause")
            }
        case UInt16(NSLeftArrowFunctionKey):
            advance(-2)
            showMessage("previous")
        case UInt16(NSRightArrowFunctionKey):
            advance(0)
            showMessage("next")
        default:
            break
        }
    }
    func advance(count: Int){
        index+=count
        if index<0{
            index = 0
        }
        isPaused = true
        isPaused = false
        if isContentPlaying && displayedController!.isTimebased(){
            displayedController?.stop()
        } else {
            playNext()
        }
    }
}


extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}
extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
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

class Banner: NSTextField {
}



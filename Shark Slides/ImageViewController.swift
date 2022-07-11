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
    var isPaused : Bool = false {
        didSet {
            if isPaused{
                timer?.stop()
                displayedController?.pause()
            } else {
                self.schedule()
                displayedController?.resume()
            }
        }
    }
    var timer:Timer? = nil
    var isContentPlaying : Bool = false
    
    var objects : Array<NSURL>?
    var autoRepeat : Bool {
        return UserDefaults.standard.bool(forKey: "repeat")
    }
    var completion : ((NSViewController) -> ())?
    var requestAccess : ((NSURL)->())?
    var interval : TimeInterval {
        return UserDefaults.standard.double(forKey: "interval") + Transition.duration()
    }
    var shuffle : Bool {
        return UserDefaults.standard.bool(forKey: "shuffle")
    }
    weak var displayedController : ShowContentViewController?
    var messageTimer : Timer?
    
    @IBOutlet weak var captureWindow: KeyCaptureView!
    @IBOutlet weak var container: NSView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func schedule(){
        timer?.stop()
        weak var sself = self
        timer = Timer(fire: { () -> () in
            sself?.playNext()
            }, autoRepeat: false, interval: interval)
        timer?.start()
    }
    
    private func finish(){
        isPaused = true
        displayedController?.stop()
        weak var sself = self
        timer?.stop()
        if let completion = self.completion{
            guard let sself = sself else { return }
            completion(sself)
        }
    }
    
    @objc private func playNext(){
        playNext(noCheck:false)
    }
    private func playNext(noCheck: Bool){
        if !noCheck && (isContentPlaying || isPaused){
            return
        }
        if let objects = objects{
            if objects.count == 0{
                finish()
                return
            }
            if objects.count == index{
                if !autoRepeat{
                    finish()
                    return
                } else {
                    index = 0
                }
            }
            let url = objects[index]
            index += 1
            var didPlay : Bool = false
            let content = ShowContentViewController.contentController(url: url, storyBoard: storyboard)
            if content != nil {
                didPlay = true
                playCount += 1
                Transition.defaultTransition()?.transtionFrom(view: self.displayedController, toView: content, parent: self, completion: nil)
                displayedController = content
                isContentPlaying = true
                weak var sself = self
                weak var ccontent = content
                content?.completion = { (shouldDelay:Bool) -> () in
                    if let sself = sself, let content = ccontent{
                        if !content.success{
                            sself.playCount -= 1
                        }
                        sself.isContentPlaying = false
                        if shouldDelay {
                            sself.schedule()
                        } else {
                            sself.playNext()
                        }
                    }
                }
            }
            if !didPlay{
                if !autoRepeat || playCount == 0 && objects.count == 1{
                    finish()
                } else {
                    weak var sself = self
                    DispatchQueue.main.async {
                        sself?.playNext()
                    }
                }
            }
        }
    }
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.layer?.backgroundColor = NSColor.black.cgColor
        view.window?.styleMask.update(with: .fullScreen)
        NSMenu.setMenuBarVisible(false)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.view.window?.close()
        NSMenu.setMenuBarVisible(true)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(captureWindow)
        if shuffle{
            objects?.shuffle()
        }
        self.container.isHidden = false
        weak var sself = self
        Timer(fire: { () -> () in
            sself?.playNext()
            }, autoRepeat: false, interval: 0.5).start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container.isHidden = true
        self.container.layer?.backgroundColor = NSColor.clear.cgColor
        self.captureWindow.layer?.backgroundColor = NSColor.clear.cgColor
        let img = NSImage(size: NSSize(width: 1, height: 1))
        self.cursor = NSCursor(image: img, hotSpot: NSPoint(x: 0, y: 0))
    }
    
    override func cursorUpdate(with event: NSEvent) {
        self.view.addCursorRect(self.view.bounds, cursor: cursor!)
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        
    }
    
    func showMessage(message:String!){
        self.message?.removeFromSuperview()
        self.message = NSImageView()
        self.message?.translatesAutoresizingMaskIntoConstraints = false
        self.message?.cell?.image = NSImage(named: message)
        let views : [String: AnyObject] = ["message" : self.message!]
        self.view.addSubview(self.message!)
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[message]-20-|", options: [], metrics: nil, views: views))
        self.view.addConstraint(NSLayoutConstraint(item: self.message!, attribute:.centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0))
        self.message?.isHidden = false
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
                            self.message?.isHidden = true
                            self.messageTimer?.stop()
                            self.messageTimer = nil
                    })
                    
                    }, autoRepeat: false, interval: 1)
                self.messageTimer?.start()
        })
        
    }
    
    override func keyDown(with theEvent: NSEvent) {
        let unichar = (theEvent.characters! as NSString).character(at: 0)
        let command = (theEvent.modifierFlags.rawValue & NSEvent.ModifierFlags.command.rawValue) != 0
        switch unichar{
        case 27: // Escape
           finish()
        case 32: // Space
            if isPaused{
                isPaused = false
                showMessage(message:"play")
                if let displayedController = displayedController{
                    if !displayedController.isTimebased(){
                        playNext(noCheck:true)
                    }
                } else {
                    playNext(noCheck:true)
                }
                
            } else {
                isPaused = true
                showMessage(message:"pause")
            }
        case UInt16(NSLeftArrowFunctionKey):
            if let displayedController = displayedController{
                if !command && displayedController.isKind(of: ShowVideoContentViewController.self){
                    let video = displayedController as! ShowVideoContentViewController
                    video.skip(interval: UserDefaults.standard.double(forKey: "video.skipInterval")*(-1.0))
                    break
                }
            }
            
            advance(count:-2)
            showMessage(message:"previous")
        case UInt16(NSRightArrowFunctionKey):
            if let displayedController = displayedController{
                if !command && displayedController.isKind(of: ShowVideoContentViewController.self){
                    let video = displayedController as! ShowVideoContentViewController
                    video.skip(interval:UserDefaults.standard.double(forKey:"video.skipInterval"))
                    break
                }
                
            }
            advance(count:0)
            showMessage(message:"next")
        default:
            break
        }
    }
    func advance(count: Int){
        displayedController?.stop()
        index+=count
        if index<0{
            index = 0
        }
        DispatchQueue.main.async {
            self.playNext(noCheck:true)
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



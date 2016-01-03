//
//  ImageViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 28/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Cocoa
import MediaLibrary



class ImageViewController: NSViewController {

    var media : MLMediaGroup?
    var index : Int = 0
    var isObservingMedia : Bool = false
    var playCount : Int = 0
    var isPaused : Bool = true {
        didSet{
            if !isPaused{
                timer = Timer(fire: { () -> () in
                    self.playNext()
                    }, autoRepeat: true, interval: interval)
                timer?.start()
            } else {
                timer?.stop()
                timer = nil
            }
        }
    }
    var objects : Array<MLMediaObject>?
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
    var displayedController : NSViewController?
    
    @IBOutlet weak var loading: NSProgressIndicator!
    @IBOutlet weak var captureWindow: KeyCaptureView!
    @IBOutlet weak var container: NSView!

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        mediaLoaded(true)
    }
    
    
    private func finish(){
        isPaused = true
        if isObservingMedia{
            media?.removeObserver(self, forKeyPath: "mediaObjects")
        }
        if let completion = self.completion{
            completion(vc:self)
        }
    }
    
    private func playNext(){
        if let objects = objects{
            if objects.count == 0{
                finish()
                return
            }
            let object = objects[index]
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
            if let url = object.URL{
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
                    
                }
                /*
                var type: AnyObject?
                do {
                    try url.getResourceValue(&type, forKey: NSURLTypeIdentifierKey)
                    if let type = type as? String {
                        if UTTypeConformsTo(type, kUTTypeImage as String) || UTTypeConformsTo(type, kUTTypeImage as String){
                            if let image = NSImage(contentsOfURL: url){
                                imageView.image = image
                                didPlay = true
                                ++playCount
                            }
                        }
                    }

                } catch {
                    // nothing
                }*/
                url.stopAccessingSecurityScopedResource()
            }
            
            if !didPlay{
                dispatch_after(0, dispatch_get_main_queue(), {
                    self.playNext()
                })
            }
        }
    }
    
    private func mediaLoaded(fromObserver: Bool){
        if media?.mediaObjects != nil{
            objects = media?.mediaObjects!
            if shuffle{
                objects?.shuffleInPlace()
            }
            loading.stopAnimation(nil)
            self.container.hidden = false
            if fromObserver{
                media?.removeObserver(self, forKeyPath: "mediaObjects")
                isObservingMedia = false
            }
            isPaused = false
            playNext()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        self.view.layer?.backgroundColor = NSColor.blackColor().CGColor
        view.window?.toggleFullScreen(nil)
    }
    override func viewWillDisappear() {
        super.viewWillDisappear()
    }
    override func viewDidDisappear() {
        super.viewDidDisappear()
        self.view.window?.close()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.makeFirstResponder(captureWindow)
        self.loading.startAnimation(nil)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            if self.media?.mediaObjects != nil{
                self.mediaLoaded(false)
            } else {
                self.media?.addObserver(self, forKeyPath: "mediaObjects", options: NSKeyValueObservingOptions.New, context: nil)
                self.isObservingMedia = true
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.container.hidden = true
        self.container.layer?.backgroundColor = NSColor.clearColor().CGColor
        self.captureWindow.layer?.backgroundColor = NSColor.clearColor().CGColor
    }
    
    override func mouseUp(theEvent: NSEvent) {
        
    }
    
    private func togglePause(){
        // isPaused ^= true // If swift was a real language
        if isPaused == true{
            isPaused = false
        } else {
            isPaused = true
        }
    }
    
    override func keyDown(theEvent: NSEvent) {
        let unichar = (theEvent.characters! as NSString).characterAtIndex(0)
        switch unichar{
        case 27: // Escape
           finish()
        case 32: // Space
            togglePause()
        case UInt16(NSLeftArrowFunctionKey):
            isPaused = true
            index-=2
            if index<0{
                index = 0
            }
            playNext()
        case UInt16(NSRightArrowFunctionKey):
            isPaused = true
            playNext()
        default:
            break
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


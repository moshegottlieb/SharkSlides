//
//  ShowVideoContentViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 04/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa
import AVKit
import AVFoundation

class ShowVideoContentViewController: ShowContentViewController {

    @IBOutlet weak var player: AVPlayerView!
    
    
    
    override class func isSupported(uti:String) -> Bool{
        if UTTypeConformsTo(uti, kUTTypeAVIMovie as String){
            return false // explicitly decline AVIs as those are usually not supported by quicktime
        }
        for support in AVURLAsset.audiovisualTypes(){
            if UTTypeConformsTo(support, uti){
                return true
            }
        }
        return false
    }


    override func loadContent(url: NSURL!) -> Bool {
        return true
    }

    func finishedPlayback(){
        didPlay(false)
    }
    
    override func isTimebased() -> Bool {
        return true
    }
    
    override func pause() {
        super.pause()
        self.player.player?.pause()
    }
    override func resume() {
        self.player.player?.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.player.player = AVPlayer(URL: url)
        if let player = player.player{
            player.addObserver(self, forKeyPath: "status", options: .New, context: nil)
            playerObserverd = true
            if let currentItem = player.currentItem{
                currentItem.addObserver(self, forKeyPath: "status", options: .New, context: nil)
                itemObserverd = true
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("finishedPlayback"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.player.player?.currentItem)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("finishedPlayback"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.player?.currentItem)
                player.play()
                if NSUserDefaults.standardUserDefaults().boolForKey("video.showControls"){
                    self.player.controlsStyle = AVPlayerViewControlsStyle.Default
                }
                if currentItem.status == .Failed{
                    stop()
                } else {
                    let sec = CMTime(seconds: 1, preferredTimescale: 1)
                    weak var sself = self
                    timeObserver = player.addPeriodicTimeObserverForInterval(sec, queue: nil, usingBlock: { (time:CMTime) -> Void in
                        if let sself = sself, timeObserver = sself.timeObserver {
                            sself.success = true
                            player.removeTimeObserver(timeObserver)
                            sself.timeObserver = nil
                        }
                    })
                }
                
            }
            
        }
    }
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let player = object as? AVPlayer{
            if keyPath! == "status" && player == self.player.player{
                if player.status == .Failed{
                    stop()
                }
            }
        } else if let item = object as? AVPlayerItem{
            if keyPath! == "status"{
                if item.status == .Failed{
                    stop()
                }
            }
        }
    }
    
    override func stop() {
        cleanup()
        super.stop()
        if (self.player.player?.currentItem != nil){
            self.player.player?.replaceCurrentItemWithPlayerItem(nil)
            finishedPlayback()
        }
    }
    
    func skip(interval: NSTimeInterval){
        if let time = player.player?.currentTime(){
            let zero = CMTime(seconds: 0, preferredTimescale: 1)
            var new_time = time + CMTimeMakeWithSeconds(interval,1)
            if new_time < zero{
                new_time = zero
            }
            self.player.player?.seekToTime(new_time, toleranceBefore: zero, toleranceAfter: zero) 
        }
    }
    
    private func cleanup(){
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if let timeObserver = timeObserver{
            self.player.player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        if playerObserverd{
            self.player.player?.currentItem?.removeObserver(self, forKeyPath: "status")
            playerObserverd = false
        }
        if itemObserverd{
            self.player.player?.removeObserver(self, forKeyPath: "status")
            itemObserverd = false
        }
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        cleanup()
        if (self.player.player?.currentItem != nil){
            self.player.player?.replaceCurrentItemWithPlayerItem(nil)
        }
    }
        
    private var timeObserver : AnyObject? = nil
    private var playerObserverd : Bool = false
    private var itemObserverd : Bool = false
    
}

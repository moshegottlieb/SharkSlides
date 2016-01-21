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
        self.url.startAccessingSecurityScopedResource()
        self.player.player = AVPlayer(URL: url)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("finishedPlayback"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.player.player?.currentItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("finishedPlayback"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player.player?.currentItem)
        player.player?.play()
        if NSUserDefaults.standardUserDefaults().boolForKey("video.showControls"){
            player.controlsStyle = AVPlayerViewControlsStyle.Default
        }
        if player.player?.currentItem?.status == .Failed{
            stop()
        }
    }
    
    override func stop() {
        super.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
    override func viewWillDisappear() {
        super.viewWillDisappear()
        if (self.player.player?.currentItem != nil){
            self.player.player?.replaceCurrentItemWithPlayerItem(nil)
        }
    }
    
    deinit{
        self.url.stopAccessingSecurityScopedResource()
    }
    
}

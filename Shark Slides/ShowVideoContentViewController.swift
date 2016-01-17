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
        self.player.player?.play()
    }
    
    override func stop() {
        super.stop()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        if (self.player.player?.currentItem != nil){
            self.player.player?.replaceCurrentItemWithPlayerItem(nil)
            finishedPlayback()
        }
    }
    
    deinit{
        self.url.stopAccessingSecurityScopedResource()
    }
    
}

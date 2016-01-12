//
//  Timer.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 29/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Foundation

class Timer {
    private let fire : (() -> ())!
    private weak var timer : NSTimer?
    private var autoRepeat : Bool
    private var interval : NSTimeInterval
    private var sself : Timer?
    required init(fire:(() -> ())! , autoRepeat:Bool, interval:NSTimeInterval){
        self.autoRepeat = autoRepeat
        self.interval = interval
        self.fire = fire
    }
    
    @objc func fired(){
        fire()
        if !autoRepeat{
            stop() // clear sself, mostly
        }
    }
    
    func stop(){
        if let timer = self.timer{
            timer.invalidate()
        }
        sself = nil
    }
    func start(){
        self.timer?.invalidate()
        let timer : NSTimer! = NSTimer(timeInterval: interval, target: self, selector: Selector("fired"), userInfo: nil, repeats: autoRepeat)
        self.timer = timer
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        assert(timer != nil)
        sself = self
    }
    deinit{
        stop()
    }
}

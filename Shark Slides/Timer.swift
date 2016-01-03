//
//  Timer.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 29/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Foundation


class Timer{
    private let fire : (() -> ())!
    private let autoRepeat : Bool
    private let interval : NSTimeInterval
    private var running: Bool = false
    private var sself : Timer?
    required init(fire:(() -> ())! , autoRepeat:Bool, interval:NSTimeInterval){
        self.fire = fire
        self.autoRepeat = autoRepeat
        self.interval = interval
    }
    
    private func schedule(){
        weak var sself = self.sself
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
            if let sself = sself{
                sself.fire()
                if sself.autoRepeat{
                    sself.schedule()
                }
            }
        })
    }
    
    func stop(){
        running = false
        sself = nil
    }
    func start(){
        assert(!running)
        running = true
        sself = self
        schedule()
    }
}
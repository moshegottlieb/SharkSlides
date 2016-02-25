//
//  Transition.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 03/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Foundation
import Cocoa


class Transition : NSObject{
    static func defaultTransition() -> Transition?{
        if let transition = NSUserDefaults.standardUserDefaults().stringForKey("transition"){
            switch (transition){
            case "Fade":
                return FadeTransition()
            case "None":
                return FadeTransition()
            default:
                return nil
            }
        }
        return nil
    }
    
    static func duration() -> NSTimeInterval{
        if let transition = NSUserDefaults.standardUserDefaults().stringForKey("transition"){
            switch (transition){
            case "None":
                return 0
            default:
                break
            }
        }
        return NSUserDefaults.standardUserDefaults().doubleForKey("transition.duration")
    }
    
    var parent : NSViewController! = nil

    func willShowView(view:NSView!){
        view.translatesAutoresizingMaskIntoConstraints = false
        self.parent.view.addSubview(view)
        let views = ["view":view]
        self.parent.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[view]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        self.parent.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options:NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
    }
    func willHideView(view:NSView!){
        
    }
    func hideView(view:NSView!){
    }
    func showView(view:NSView!){
        
    }

    
    func transtionFrom(view:NSViewController?, toView:NSViewController!, parent:NSViewController! ,completion:(() -> ())?){
        self.parent = parent
        parent.addChildViewController(toView)
        willShowView(toView.view)
        if let view = view{
            weak var sself = self
            weak var ttoView = toView
            NSAnimationContext.runAnimationGroup({ (context : NSAnimationContext) -> Void in
                if let sself = sself, toView = ttoView {
                    context.duration = Transition.duration()
                    sself.hideView(view.view)
                    sself.showView(toView.view)
                }
                }, completionHandler: {
                    view.view.removeFromSuperview()
                    view.removeFromParentViewController()
                    if let completion = completion{
                        completion()
                    }
            })
        } else {
            self.showView(toView.view)
            if let completion = completion{
                completion()
            }
        }
    }
}
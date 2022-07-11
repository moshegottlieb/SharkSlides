//
//  ReplaceSegue.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 25/02/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class ReplaceSegue: NSStoryboardSegue {
    override func perform() {
        let parent = sourceController as! NSViewController
        let toView = destinationController as! NSViewController
        let from = (parent).children.first
        parent.addChild(toView)
        parent.view.addSubview(toView.view)
        toView.view.translatesAutoresizingMaskIntoConstraints = false
        let views = ["to":toView.view]
        parent.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[to]-0-|", options: [], metrics: nil, views: views))
        parent.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[to]-0-|", options: [], metrics: nil, views: views))
        from?.removeFromParent()
        from?.view.removeFromSuperview()
    }
}

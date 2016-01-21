//
//  FadeInSegue.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 18/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class FadeInSegue: NSStoryboardSegue {
    override func perform() {
        let fade = FadeTransition()
        let parent = self.sourceController as! NSViewController
        let from = (parent).childViewControllers.first
        let to = self.destinationController as! NSViewController
        fade.transtionFrom(from, toView: to, parent: parent, completion: nil)
    }
}

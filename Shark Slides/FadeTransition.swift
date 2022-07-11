//
//  FadeTransition.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 03/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class FadeTransition: Transition {
    
    override func willShowView(view:NSView!){
        super.willShowView(view: view)
        view.alphaValue = 0
    }
    override func willHideView(view:NSView!){
        super.willHideView(view: view)
    }
    override func hideView(view:NSView!){
        super.hideView(view: view)
        view.animator().alphaValue = 0
    }
    override func showView(view:NSView!){
        super.showView(view: view)
        view.animator().alphaValue = 1
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = FadeTransition()
        return copy
    }
}

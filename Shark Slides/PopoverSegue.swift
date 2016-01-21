//
//  PopoverSegue.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 21/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class PopoverSegue: NSStoryboardSegue {
    override func perform() {
        let main = NSApp.mainWindow?.contentViewController as? About
        if let main = main{
            main.about()
        } else if let main = NSApp.mainWindow?.contentViewController?.view.window?.windowController as? About{
            main.about()
        }
        
    }

}

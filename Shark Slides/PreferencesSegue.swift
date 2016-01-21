//
//  PreferencesSegue.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 22/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

protocol Preferences{
    func preferences()
}

class PreferencesSegue: NSStoryboardSegue {
    override func perform() {
        let main = NSApp.mainWindow?.contentViewController as? Preferences
        main?.preferences()
    }
}

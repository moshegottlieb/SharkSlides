//
//  AppDelegate.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 25/11/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserDefaults.standardUserDefaults().registerDefaults(["interval":1.0,"shuffle":true, "transition.duration":0.3, "transition":"Fade"])
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}
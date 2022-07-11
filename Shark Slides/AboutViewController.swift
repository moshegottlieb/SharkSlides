//
//  AboutViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 18/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {

    @IBOutlet weak var aboutLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        let bundle = Bundle.main
        let info = bundle.infoDictionary!
        let name = info[kCFBundleNameKey as String] as! String
        let build = info[kCFBundleVersionKey as String] as! String
        let ver = info["CFBundleShortVersionString"] as! String
        let fmt = NSLocalizedString("ABOUT", comment: "About")
        let about = String(format: fmt, name,ver,build)
        aboutLabel.cell?.stringValue = about
    }
    
    @IBAction func openLink(sender: AnyObject) {
        NSWorkspace.shared.open(URL(string: "http://sharkfood.com")!)
        self.view.window?.orderOut(self)
    }
}

protocol About{
    func about()
}

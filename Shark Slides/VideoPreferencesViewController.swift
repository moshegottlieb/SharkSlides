//
//  VideoPreferencesViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 18/01/2016.
//  Copyright © 2016 Sharkfood. All rights reserved.
//

import Cocoa

class VideoPreferencesViewController: NSViewController {
    let skipTimesTitles : [String]!
    let skipTimesValues : [NSTimeInterval]!
    @IBOutlet weak var skipTimes: NSPopUpButton!

    required init?(coder: NSCoder) {
        skipTimesTitles = [NSLocalizedString("SEC_5", comment: "5 seconds"),NSLocalizedString("SEC_10", comment: "10 seconds"),NSLocalizedString("SEC_30", comment: "30 seconds")]
        skipTimesValues = [5,10,30]
        super.init(coder: coder)
    }
    
    @IBAction func skipChanged(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setDouble(skipTimesValues[skipTimes.indexOfSelectedItem], forKey: "video.skipInterval")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var index = 0
        let selection = NSUserDefaults.standardUserDefaults().doubleForKey("video.skipInterval")
        for (index = 0; index < skipTimesValues.count;++index){
            if skipTimesValues[index] == selection{
                break
            }
        }
        self.skipTimes.selectItemAtIndex(index)
    }
    
}

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
    let skipTimesValues : [TimeInterval]!
    @IBOutlet weak var skipTimes: NSPopUpButton!

    required init?(coder: NSCoder) {
        skipTimesTitles = [NSLocalizedString("SEC_5", comment: "5 seconds"),NSLocalizedString("SEC_10", comment: "10 seconds"),NSLocalizedString("SEC_30", comment: "30 seconds")]
        skipTimesValues = [5,10,30]
        super.init(coder: coder)
    }
    
    @IBAction func skipChanged(sender: AnyObject) {
        UserDefaults.standard.set(skipTimesValues[skipTimes.indexOfSelectedItem], forKey: "video.skipInterval")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let selection = UserDefaults.standard.double(forKey: "video.skipInterval")
        let index:Int
        for index in 0..<skipTimesValues.count {
            if skipTimesValues[index] == selection{
                break
            }
        }
        self.skipTimes.selectItem(at: index)
    }
    
}

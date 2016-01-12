//
//  SelectLibraryController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 27/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Cocoa
import MediaLibrary


class MainWindow : NSWindow{
    override func performClose(sender: AnyObject?) {
        super.performClose(sender)
        NSApp.terminate(sender)
    }
}

class MainViewController: NSViewController {

    private var mediaLibrary : MediaLibrary?
    let transitions = ["Fade"]
    
    var source : MLMediaGroup? {
        didSet{
            if let name = source?.name{
                sourceButton.cell?.title = name
            }
            startButton.enabled = source != nil
        }
    }
    private var accessURL: NSURL?
    
    @IBOutlet weak var sourceButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear() {
        super.viewWillAppear()
        if mediaLibrary == nil{
            mediaLibrary = MediaLibrary()
            var loading : LoadingController
            loading = (storyboard?.instantiateControllerWithIdentifier("LoadingController"))! as! LoadingController
            loading.completion = {
                loading.setMessageText(NSLocalizedString("LOADING_PHOTOS", comment: "Loading photos"))
                self.mediaLibrary!.load { () -> () in
                    loading.dismissController(self)
                    self.source = self.mediaLibrary?.photosSource.rootMediaGroup
                }
            }
            self.presentViewControllerAsSheet(loading)
            
        }
    }
    @IBAction func selectSource(sender: AnyObject) {
        let select = storyboard?.instantiateControllerWithIdentifier("SourceSelectViewController") as! SourceSelectViewController
        select.rootGroup = mediaLibrary?.photosSource.rootMediaGroup
        select.selection = source
        select.completion = { (selection:MLMediaGroup!) in
            self.source = selection
        }
        presentViewControllerAsSheet(select)
    }
    
    @IBAction func play(sender: NSButton?) {
        
        
        
        var loading : LoadingController?
        if !self.mediaLibrary!.loadGroup(self.source!, completion: { () -> () in
            loading?.dismissController(self)
            let vc = self.storyboard?.instantiateControllerWithIdentifier("ImageViewController") as! ImageViewController
            var objects = Array<NSURL>()
            objects.reserveCapacity((self.source?.mediaObjects?.count)!)
            for object in self.source!.mediaObjects!{
                if let url = object.URL{
                    objects.append(url)
                }
            }
            vc.objects = objects
            vc.completion = { ( vc : NSViewController!) in
                self.view.window?.makeKeyAndOrderFront(nil)
                self.dismissViewController(vc)
                vc.view.window?.close()
            }
            vc.requestAccess = { (url: NSURL!) in
                self.accessURL = url
                if let url = self.accessURL{
                    self.accessURL = nil
                    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                    dispatch_after(delayTime, dispatch_get_main_queue(), { () -> Void in
                        var path = (url.path as NSString!).stringByStandardizingPath
                        while (path as NSString).length > 0 && !path.hasSuffix("Photos Library.photoslibrary"){
                            path = (path as NSString).stringByDeletingLastPathComponent
                        }
                        let panel = NSOpenPanel()
                        panel.canChooseFiles = true
                        panel.allowedFileTypes = ["photoslibrary"]
                        panel.canChooseDirectories = false
                        panel.allowsMultipleSelection = false
                        panel.message = NSLocalizedString("OPEN_PANEL_GRANT_ACCESS",comment:"")
                        panel.directoryURL = NSURL(fileURLWithPath: path)
                        panel.beginWithCompletionHandler({ (result: Int) -> Void in
                            if result == NSFileHandlingPanelOKButton{
                                panel.URL?.saveBookmark()
                                self.play(nil)
                            }
                        })
                        
                    })
                    
                }
                
            }
            self.presentViewControllerAsModalWindow(vc)
            self.view.window?.orderOut(nil)
        }){
            loading = (storyboard?.instantiateControllerWithIdentifier("LoadingController"))! as? LoadingController
            loading?.completion = {
                loading?.setMessageText(NSLocalizedString("LOADING_SOURCE", comment: "Loading photos"))
            }
            self.presentViewControllerAsSheet(loading!)
        }
        
        
        
    }
}

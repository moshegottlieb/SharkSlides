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

class MainViewController: NSViewController , About, Preferences{

    private var mediaLibrary : MediaLibrary?
    
    private func setSource(name:String!,icon:NSImage!){
        sourceIcon.image = icon
        pathTitle.cell?.stringValue = name
    }
    
    @IBOutlet weak var infoButton: NSButton!
    @IBOutlet weak var preferencesButton: NSButton!
    
    func about(){
        infoButton.target?.performSelector(infoButton.action, withObject: self)
    }
    func preferences() {
        preferencesButton.target?.performSelector(preferencesButton.action, withObject: self)
    }
    
    var source : MLMediaGroup? {
        didSet{
            if let source = source{
                var loading : LoadingController?
                loading = (storyboard?.instantiateControllerWithIdentifier("LoadingController"))! as? LoadingController
                loading?.completion = {
                    loading?.setMessageText(NSLocalizedString("LOADING_SOURCE", comment: "Loading photos"))
                }
                if !self.mediaLibrary!.loadGroup(source, completion: { () -> () in
                    loading?.dismissController(self)
                    var objects = Array<NSURL>()
                    objects.reserveCapacity((self.source?.mediaObjects?.count)!)
                    for object in source.mediaObjects!{
                        if let url = object.URL{
                            objects.append(url)
                        }
                    }
                    self.urls = objects
                    if objects.count > 0{
                        let format = NSLocalizedString("FILE_COUNT", comment: "")
                        self.setSource(String(format:format , arguments: [objects.count as Int]), icon: NSImage(named: "photos"))
                        NSURL.deleteBookmarks()
                    }
                }){
                    self.presentViewControllerAsSheet(loading!)
                }
            }
        }
    }

    
    var urls : Array<NSURL>? = nil {
        didSet {
            startButton.enabled = false
            if urls?.count > 0{
                startButton.enabled = true
            } else {
                let icon = NSImage(named:"warning")
                setSource(NSLocalizedString("NO_SELECTION", comment: "Nothing selected"), icon: icon)
                if urls != nil{
                    let alert = NSAlert()
                    alert.messageText = NSLocalizedString("ALERT_NO_URLS", comment: "No playable items found")
                    alert.informativeText = NSLocalizedString("ALERT_NO_URL_INFO", comment: "")
                    alert.alertStyle = .WarningAlertStyle
                    alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                    alert.icon = icon
                    
                }
            }
            
        }
    }
    
    private var accessURL: NSURL?
    
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var pathTitle: NSTextField!
    @IBOutlet weak var sourceIcon: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.urls = nil
        if let urls = NSURL.loadBookmarks(){
            loadFinderUrls(urls)
        }
    }
    @IBAction func selectSource(sender: AnyObject) {
        if mediaLibrary == nil{
            mediaLibrary = MediaLibrary()
            var loading : LoadingController
            loading = (storyboard?.instantiateControllerWithIdentifier("LoadingController"))! as! LoadingController
            loading.completion = {
                loading.setMessageText(NSLocalizedString("LOADING_PHOTOS", comment: "Loading photos"))
                self.mediaLibrary!.load { () -> () in
                    loading.dismissController(self)
                    self.selectSource(sender)
                }
            }
            self.presentViewControllerAsSheet(loading)
        } else {

            let select = storyboard?.instantiateControllerWithIdentifier("SourceSelectViewController") as! SourceSelectViewController
            select.rootGroup = mediaLibrary?.photosSource.rootMediaGroup
            select.selection = source
            select.completion = { (selection:MLMediaGroup!) in
                self.source = selection
            }
            presentViewControllerAsSheet(select)
        }
    }
    
    
    private func loadUrls(inout result:Array<NSURL>!, urls: Array<NSURL>!){
        for url in urls{
            var type: AnyObject?
            do {
                try url.getResourceValue(&type, forKey: NSURLTypeIdentifierKey)
                if let type = type as? String {
                    if ShowContentViewController.isSupported(type){
                        result.append(url)
                    } else if UTTypeConformsTo(type, kUTTypeFolder as String){
                        var contents : Array<NSURL>!
                        var options : NSDirectoryEnumerationOptions = .SkipsSubdirectoryDescendants
                        options = options.union(.SkipsPackageDescendants)
                        options = options.union(.SkipsHiddenFiles)
                        contents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: nil, options:  options)
                        loadUrls(&result, urls: contents)
                    }
                }
                
            } catch {
                // nothing
            }
        }
    }
    
    private func loadFinderUrls(urls:Array<NSURL>!) -> Bool{
        var result : Array<NSURL>! = Array<NSURL>()
        self.loadUrls(&result,urls: urls)
        self.urls = result
        if result.count > 0{
            let format = NSLocalizedString("FILE_COUNT", comment: "")
            self.setSource(String(format:format , arguments: [result.count as Int]), icon: NSImage(named:"finder"))
            return true
        }
        return false
    }
    
    @IBAction func chooseFromFinder(sender: AnyObject) {
        let open = NSOpenPanel() as NSOpenPanel
        open.canChooseDirectories = true
        open.canChooseFiles = true
        open.allowsMultipleSelection = true
        open.message = NSLocalizedString("OPEN_FILE_MESSAGE", comment: "Choose images/videos")
        open.allowedFileTypes = [kUTTypeAudiovisualContent as String,kUTTypeImage as String]
        open.prompt = NSLocalizedString("OPEN_FILE_PROMPT", comment: "Choose")
        open.beginSheetModalForWindow(view.window!) { (result:Int) -> Void in
            if result == NSFileHandlingPanelOKButton{
                if self.loadFinderUrls(open.URLs){
                    NSURL.saveBookmarks(open.URLs)
                } else {
                    NSURL.deleteBookmarks()
                }
            }
        }
    }
    
    @IBAction func play(sender: NSButton?) {
        let vc = self.storyboard?.instantiateControllerWithIdentifier("ImageViewController") as! ImageViewController
        vc.objects = urls
        vc.completion = { ( vc : NSViewController!) in
            self.view.window?.makeKeyAndOrderFront(nil)
            self.dismissViewController(vc)
            vc.view.window?.close()
        }
    
        presentViewControllerAsModalWindow(vc)
        view.window?.orderOut(nil)
    }
}

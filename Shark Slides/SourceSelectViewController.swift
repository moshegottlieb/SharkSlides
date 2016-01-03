//
//  SourceSelectViewController.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 27/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Cocoa
import MediaLibrary

class boxedArray<T>{
    var array:Array<T> = [T]()
    subscript(index:Int) -> T {
        get {
            return array[index]
        }
        set(newValue){
            array[index] = newValue
        }
    }
    var count :Int {
        return array.count
    }
    func append(newElement:T){
        array.append(newElement)
    }
}

class SourceSelectViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate{

    
    var rootGroup : MLMediaGroup?
    var selection : MLMediaGroup?
    
    
    var completion : ((selection:MLMediaGroup!) -> ())?
    @IBOutlet weak var outlineView: NSOutlineView!
    
    @IBAction func cancel(sender: NSButton) {
        dismissController(sender)
    }
    @IBAction func ok(sender: NSButton) {
        if let completion = self.completion{
            completion(selection: selection)
        }
        dismissController(sender)
    }
    
    private func lookup(result:boxedArray<MLMediaGroup>!, position:MLMediaGroup!) ->Bool{
        if position == selection{
            return true;
        }
        if let childGroups = position.childGroups{
            for group in childGroups{
                if lookup(result, position: group){
                    result.append(position)
                    return true
                }
            }
        }
        return false
    }
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask = NSBorderlessWindowMask
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tree:boxedArray<MLMediaGroup> = boxedArray<MLMediaGroup>()
        lookup(tree, position: rootGroup)
        for var i:Int = tree.count-1; i>=0; --i{
            outlineView.expandItem(tree[i])
        }
        outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(selection)), byExtendingSelection: false)
    }
    
    func outlineView(outlineView: NSOutlineView,
        child index: Int,
        ofItem item: AnyObject?) -> AnyObject{
            if item == nil{
                return rootGroup!
            }
            let group : MLMediaGroup = item as! MLMediaGroup!
            return group.childGroups![index]
    }
    
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return (item as! MLMediaGroup).childGroups?.count > 0
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if item == nil{
            return 1
        }
        return ((item as! MLMediaGroup).childGroups?.count)!
    }
    
    func outlineView(outlineView: NSOutlineView, willDisplayCell cell: AnyObject, forTableColumn tableColumn: NSTableColumn?, item: AnyObject) {
        if let imageCell = cell as? NSImageCell{
            if let image = (item as? MLMediaGroup)?.iconImage{
                imageCell.image = image
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
                    outlineView.reloadItem(item)
                })
            }
        } else {
            if let textCell = cell as? NSTextFieldCell{
                if let name = (item as? MLMediaGroup)?.name{
                    textCell.title = name
                }
            }
        }
        if (item as! MLMediaGroup) == selection{
            outlineView.selectRowIndexes(NSIndexSet(index: outlineView.rowForItem(item)), byExtendingSelection: false)
        }
    }
    
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        self.selection = item as? MLMediaGroup
        return true
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        self.outlineView.tableColumns[1].width = self.outlineView.bounds.size.width - self.outlineView.tableColumns[0].width;
    }
    
}

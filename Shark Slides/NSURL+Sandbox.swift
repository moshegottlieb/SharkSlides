//
//  NSURL+Sandbox.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 29/12/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

import Foundation

extension NSURL {
    func standardPath() -> String? {
        if let path = self.path{
            return (path as NSString).stringByStandardizingPath
        }
        return nil
    }
    
    class func saveBookmarks(urls: Array<NSURL>!){
        deleteBookmarks()
        var data_array : Array<NSData> = Array()
        data_array.reserveCapacity(urls.count)
        for url in urls{
            if let data = try? url.bookmarkDataWithOptions(.SecurityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeToURL: nil){
                data_array.append(data)
            }
        }
        if data_array.count > 0{
            NSUserDefaults.standardUserDefaults().setObject(data_array, forKey: "bookmarks")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    class func deleteBookmarks(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("bookmarks")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func loadBookmarks() -> Array<NSURL>?{
        let data_array = NSUserDefaults.standardUserDefaults().arrayForKey("bookmarks") as? Array<NSData>
        if data_array?.count > 0{
            var urls : Array<NSURL> = Array()
            for data in data_array!{
                var isStale : ObjCBool = false
                if let url = try? NSURL(byResolvingBookmarkData: data, options: .WithoutUI, relativeToURL: nil, bookmarkDataIsStale: &isStale){
                    if !isStale{
                        urls.append(url)
                    }
                }
            }
            if urls.count > 0{
                return urls
            }
        }
        return nil
    }
    
}
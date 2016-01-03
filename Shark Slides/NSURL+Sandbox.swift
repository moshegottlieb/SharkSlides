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
    static var picturesPath : String! {
        let pw  = getpwuid(getuid())
        var home : String! = String.fromCString(pw.memory.pw_dir)
        home = (home as NSString).stringByAppendingPathComponent("Pictures")
        return NSURL(fileURLWithPath: home).standardPath()
    }
    func saveBookmark(){
        if let data = try? bookmarkDataWithOptions(.SecurityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeToURL: nil){
            var dict = NSUserDefaults.standardUserDefaults().dictionaryForKey("bookmarks")
            if var dict = dict{
                dict[standardPath()!] = data
            }
            else {
                dict = [standardPath()!:data]
            }
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "bookmarks")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }

    func isSandboxed() -> Bool {
        if !checkPromisedItemIsReachableAndReturnError(nil){
            let dict = NSUserDefaults.standardUserDefaults().dictionaryForKey("bookmarks")
            if let dict = dict{
                var data : NSData?
                data = dict[standardPath()!]?.data
                if let data = data{
                    var isStale : ObjCBool = false
                    if let _ = try? NSURL(byResolvingBookmarkData: data, options: .WithoutUI, relativeToURL: nil, bookmarkDataIsStale: &isStale){
                        startAccessingSecurityScopedResource()
                        return false
                    }
                }
            }
        } else {
            return false
        }
        return true
    }
}
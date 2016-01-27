//
//  MediaLibrary.swift
//  Shark Slides
//
//  Created by Moshe Gottlieb on 25/11/2015.
//  Copyright © 2015 Sharkfood. All rights reserved.
//

    import Foundation
    import MediaLibrary

    public class MediaLibrary : NSObject{
        var photosSource : MLMediaSource!
        private weak var group : MLMediaGroup?
        private var library : MLMediaLibrary!
        private var completion : (() -> ())?
        
        private func loadSources(){
            if let mediaSources = library.mediaSources {
                photosSource = mediaSources[MLMediaSourcePhotosIdentifier]
                if photosSource != nil{
                    photosSource.addObserver(self, forKeyPath: "rootMediaGroup", options: NSKeyValueObservingOptions.New, context: nil)
                    photosSource.rootMediaGroup; // load
                }
            }
            if photosSource == nil{
                if let completion = completion{
                    completion()
                }
            }
        }
        
        public func load(completion:()->()){
            self.completion = completion
            let options : [String : AnyObject] = [/*MLMediaLoadSourceTypesKey : MLMediaSourceType.Image.rawValue, */MLMediaLoadIncludeSourcesKey : [MLMediaSourcePhotosIdentifier]]
            library = MLMediaLibrary(options: options)
            library.addObserver(self, forKeyPath: "mediaSources", options: NSKeyValueObservingOptions.New, context: nil)
            library.mediaSources // trigger load, status will be reported back in observeValueForKeyPath
        }
        
        public func loadGroup(group:MLMediaGroup!,completion:()->()) -> Bool{
            self.completion = completion
            self.group = group
            if group.mediaObjects == nil{
                group.addObserver(self, forKeyPath: "mediaObjects", options: NSKeyValueObservingOptions.New, context: nil)
                return false
            } else {
                completion()
                return true
            }
        }
        
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            var found : Bool = false
            if let sobject = object{
                // mediaSources?
                if sobject.isKindOfClass(MLMediaLibrary){
                    loadSources();
                    library.removeObserver(self, forKeyPath: "mediaSources")
                } else if sobject.isKindOfClass(MLMediaSource){
                    if sobject as! MLMediaSource == photosSource{
                        // root group loaded
                        photosSource.removeObserver(self, forKeyPath: "rootMediaGroup")
                        found = true
                    }
                } else if keyPath == "mediaObjects"{
                    group?.removeObserver(self, forKeyPath: "mediaObjects")
                    found = true
                }
            }
            if found{
                if let scompletion = completion{
                    scompletion()
                    self.completion = nil
                }
            }
        }
        
    }
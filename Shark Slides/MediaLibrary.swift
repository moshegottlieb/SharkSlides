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
        var library : MLMediaLibrary!
        var photosSource : MLMediaSource!
        var completion : (() -> ())?
        
        private func loadSources(){
            if let mediaSources = library.mediaSources {
                photosSource = mediaSources[MLMediaSourcePhotosIdentifier]
                photosSource.addObserver(self, forKeyPath: "rootMediaGroup", options: NSKeyValueObservingOptions.New, context: nil)
                photosSource.rootMediaGroup; // load
            }
        }
        
        public func load(completion:()->()){
            self.completion = completion
            let options : [String : AnyObject] = [/*MLMediaLoadSourceTypesKey : MLMediaSourceType.Image.rawValue, */MLMediaLoadIncludeSourcesKey : [MLMediaSourcePhotosIdentifier]]
            library = MLMediaLibrary(options: options)
            library.addObserver(self, forKeyPath: "mediaSources", options: NSKeyValueObservingOptions.New, context: nil)
            library.mediaSources; // trigger load, status will be reported back in observeValueForKeyPath
        }
        
        public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
            if let sobject = object{
                // mediaSources?
                if sobject.isKindOfClass(MLMediaLibrary){
                    loadSources();
                    library.removeObserver(self, forKeyPath: "mediaSources")
                } else if sobject.isKindOfClass(MLMediaSource){
                    if sobject as! MLMediaSource == photosSource{
                        // root group loaded
                        photosSource.removeObserver(self, forKeyPath: "rootMediaGroup")
                        if let scompletion = completion{
                            scompletion()
                        }
                    }
                }
            }
        }
        
    }
//
//  Thumbnail.swift
//  DragAndDropExample
//
//  Created by Smitha Ramamurthy on 12/01/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Foundation
import AppKit

class Thumbnail {
    fileprivate(set) var image: NSImage?
    fileprivate(set) var fileName: String
    
    init?(url: URL) {
        fileName = url.lastPathComponent
        image = nil
        
        let imageSource = CGImageSourceCreateWithURL(url.absoluteURL as CFURL, nil)
        if let imageSource = imageSource {
            guard CGImageSourceGetType(imageSource) != nil else { return }
            let thumbnailOptions = [
                String(kCGImageSourceCreateThumbnailFromImageIfAbsent): true,
                String(kCGImageSourceThumbnailMaxPixelSize): 160
            ] as [String: Any]
            if let thumbnailReference = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions as CFDictionary) {
                image = NSImage(cgImage: thumbnailReference, size: NSZeroSize)
            } else {
                return nil
            }
        }
    }
}

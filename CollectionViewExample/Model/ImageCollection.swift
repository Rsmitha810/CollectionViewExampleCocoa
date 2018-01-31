//
//  ImageCollection.swift
//  DragAndDropExample
//
//  Created by Smitha Ramamurthy on 18/01/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Foundation

class ImageCollection {
    fileprivate var collectionName: String
    fileprivate var collectionURL: URL
    
    init(collectionName: String?, collectionURL: URL) {
        self.collectionName = collectionName ?? "untitled"
        self.collectionURL = collectionURL
    }
}

//
//  CollectionViewItemClass.swift
//  DragAndDropExample
//
//  Created by Smitha Ramamurthy on 10/01/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Cocoa

class CollectionViewItemClass: NSCollectionViewItem {
    
    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 3.0 : 0.0
        }
    }
    
    var thumbnail: Thumbnail? {
        didSet {
            guard isViewLoaded else { return }
            if let thumbnail = self.thumbnail {
                imageView?.image = thumbnail.image
                textField?.stringValue = thumbnail.fileName
            } else {
                imageView?.image = nil
                textField?.stringValue = ""
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.borderWidth = 0.0
        view.layer?.borderColor = NSColor.orange.cgColor
    }
    
    override func prepareForReuse() {
        self.thumbnail = nil
    }
}

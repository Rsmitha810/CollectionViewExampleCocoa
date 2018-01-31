//
//  WindowController.swift
//  DragAndDropExample
//
//  Created by Smitha Ramamurthy on 12/01/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        if let window = window, let screen = NSScreen.main {
            let screenRect = screen.visibleFrame
            window.setFrame(NSRect(x: screenRect.origin.x, y:screenRect.origin.y, width: screenRect.width / 2.0, height:screenRect.height), display: true)
        }
    }
}

extension NSOpenPanel {
    func setPreferencesForImportFolder() {
        title = "Import Folder"
        canChooseFiles = false
        canChooseDirectories = true
        showsHiddenFiles = false
        allowsMultipleSelection = false
    }
    func setPreferencesForImportImage() -> Void {
        canChooseFiles = true
        canChooseDirectories = false
        showsHiddenFiles = false
        allowsMultipleSelection = false
        allowedFileTypes = ["public.image"]
    }
}


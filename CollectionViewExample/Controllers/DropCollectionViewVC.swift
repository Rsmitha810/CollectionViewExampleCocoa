//
//  DropCollectionViewVC.swift
//  DragAndDropExample
//
//  Created by Smitha Ramamurthy on 10/01/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

//  CollectionViewExample is a simple project which lets you import a folder with images,
//  displays the images in a collection and lets you add more images from different source,
//  either using the button provided or using drag and drop.
//  After adding the images, you can save the same in the folder that you have imported.
//  If you choose to exit without pressing the save button, changes will not be saved.

import Cocoa

enum FlowLayout: CGFloat {
    case width = 160.0
    case height = 200.0
    case minimumInterimSpacing = 20.0
    case minimumLineSpacing = 25.0
}

class DropCollectionViewVC: NSViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var saveChangesButton: NSButton!
    @IBOutlet weak var addImageButton: NSButton!
    
    let imageLoader = ImagesFolderLoader()
    var folderURL: URL?
    var imageURLs: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFlowLayout()
    }
    
    //MARK: - IB Actions
    @IBAction func importFolder(_ sender: AnyObject) {
        let importPanel = NSOpenPanel()
        importPanel.setPreferencesForImportFolder()
        importPanel.beginSheetModal(for: self.view.window!) { (response) in
            guard response == NSApplication.ModalResponse.OK else { return }
            if let url = importPanel.url?.absoluteURL {
                self.loadImagesFromFolderWithURL(url)
            }
        }
    }
    
    @IBAction func addImageToCollection(_ sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.setPreferencesForImportImage()
        openPanel.beginSheetModal(for: self.view.window!) { (response) in
            guard response == NSApplication.ModalResponse.OK else { return }
            if let url = openPanel.url {
                self.imageLoader.loadDataFor(url, isNewFolder: false)
                self.collectionView.reloadData()
                self.imageURLs.append(url)
                self.saveChangesButton.isEnabled = true
            }
        }
    }
    
    @IBAction func saveChanges(_ sender: NSButton) {
        guard let url = folderURL else { return }
        let savedChanges = imageLoader.save(imageURLs, toFolder: url)
        if savedChanges { saveChangesButton.isEnabled = false }
    }
    
    //MARK: - Helper Functions
    func configureFlowLayout() {
        let flowlayout = NSCollectionViewFlowLayout()
        flowlayout.itemSize = NSSize(width: FlowLayout.width.rawValue, height: FlowLayout.height.rawValue)
        flowlayout.minimumInteritemSpacing = FlowLayout.minimumInterimSpacing.rawValue
        flowlayout.minimumLineSpacing = FlowLayout.minimumLineSpacing.rawValue
        collectionView.collectionViewLayout = flowlayout
        collectionView.wantsLayer = true
    }
    
    func loadImagesFromFolderWithURL(_ url: URL) {
        folderURL = url
        imageLoader.loadDataFor(url, isNewFolder: true)
        collectionView.reloadData()
        addImageButton.isEnabled = true
        registerForDragAndDrop()
    }
    
    func registerForDragAndDrop() {
        let NSPasteboardURLType = NSPasteboard.PasteboardType(kUTTypeURL as String)
        let acceptableTypes = [NSPasteboard.PasteboardType.tiff, NSPasteboardURLType]
        
        collectionView.registerForDraggedTypes(acceptableTypes)
        collectionView.delegate = self
    }
}

//MARK:- CollectionViewDataSource methods
extension DropCollectionViewVC: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageLoader.numberOfItemsInSection(section)
    }
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath)
        guard let collectionViewCell = cell as? CollectionViewItemClass else { return cell }
        collectionViewCell.thumbnail = imageLoader.thumbnailFor(indexPath)
        return collectionViewCell
    }
}

//MARK: - CollectionViewDelegate methods for drop operation
extension DropCollectionViewVC: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        return NSDragOperation.copy
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        draggingInfo.enumerateDraggingItems(options: NSDraggingItemEnumerationOptions.concurrent, for: collectionView, classes: [URL.ReferenceType.self], searchOptions: [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly : NSNumber(value: true)]) { (dropItem, index, stop) in
            if let url = dropItem.item as? URL {
                self.imageLoader.loadDataFor(url, isNewFolder: false)
                collectionView.reloadData()
                self.imageURLs.append(url)
                self.saveChangesButton.isEnabled = true
            }
        }
        return true
    }
}

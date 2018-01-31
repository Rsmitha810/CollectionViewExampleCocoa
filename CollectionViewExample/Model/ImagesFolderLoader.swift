//
//  ImagesFolderLoader.swift
//  DragAndDropExample
//
//  Created by Smitha Ramamurthy on 12/01/18.
//  Copyright © 2018 Smitha Ramamurthy. All rights reserved.
//

import Foundation
import AppKit

struct URLinfo {
    var folderURL: URL
    var imageURLs: [URL]
    
}

//ImageLoader class is responsible for the following functions:
//    1. Load images from directory or the image itself
//    2. Create Thumbnails for the images
//    3. Return the Thumbnail for the indexpath
//    4. Save the changes made to the collection

class ImagesFolderLoader: NSObject {
    fileprivate var images = [Thumbnail]()
    
    func loadDataFor(_ url: URL, isNewFolder: Bool) {
        var isDirectory = ObjCBool(false)
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        
        //check if provided URL is a directory or a file. If it is a directory, get URL of all the image files inside it. Else just pass on the file URL received and create Thumbnails for them.
        let fileURLs = isDirectory.boolValue ? getFileURLsFromFolder(url) : [url]
        createThumbnails(for: fileURLs!, isNewFolder: isNewFolder)
    }
    
    fileprivate func getFileURLsFromFolder(_ folderURL: URL) -> [URL]? {
        let fileManager = FileManager.default
        let options: FileManager.DirectoryEnumerationOptions = [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]
        let resourceKeys: Set<URLResourceKey> = Set([.isRegularFileKey, .typeIdentifierKey])
        guard let directoryEnumerator = fileManager.enumerator(at: folderURL, includingPropertiesForKeys: Array(resourceKeys), options: options, errorHandler: { (url, error) -> Bool in
            print("directory Enumerator error: \(error).")
            return true
        }) else { return nil }
        
        var urls: [URL] = []
        for case let url as URL in directoryEnumerator {
            do {
                //This block of code checks each url in the directory enumerator to be of type image and adds it to the urls array
                let resourceValues = try (url as URL).resourceValues(forKeys: resourceKeys)
                guard let isRegularFileResourceValue = resourceValues.isRegularFile as NSNumber? else { continue }
                guard isRegularFileResourceValue.boolValue else { continue } //check if its a regular file
                guard let fileType = resourceValues.typeIdentifier as String? else { continue }
                guard UTTypeConformsTo(fileType as CFString, "public.image" as CFString) else { continue } //check if its UTI is of type public.image
                urls.append(url)
            }
            catch {
                print("Unexpected Error occurred: \(error).")
            }
        }
        return urls
    }
    
    fileprivate func createThumbnails(for urls: [URL], isNewFolder: Bool) {
        //If Import folder button is selected, then all the items in the collection need to be removed.
        if images.count > 0 && isNewFolder {
            images.removeAll()
        }
        for url in urls {
            if let thumbnail = Thumbnail(url: url) {
                images.append(thumbnail)
            }
        }
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return images.count
    }
    
    func thumbnailFor(_ indexPath: IndexPath) -> Thumbnail {
        return images[indexPath.item]
    }
    
    func save(_ imageURLs: [URL], toFolder folderURL: URL) -> Bool {
        _ = imageURLs.map { (imageURL) in
            let image = NSImage(contentsOf: imageURL)
            
            //get tiff representation of the image, convert it into file type png and save it in the folder 
            guard let tiffData = image?.tiffRepresentation else {
                print("Failed to get tiff representation for image: \(imageURL.lastPathComponent)")
                return
            }
            let imageRep = NSBitmapImageRep(data: tiffData)
            guard let imageData = imageRep?.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) else {
                print("Failed to get PNG representation for image: \(imageURL.lastPathComponent)")
                return
            }
            do {
                let path = folderURL.path
                let toURL = URL(fileURLWithPath: path).appendingPathComponent(imageURL.lastPathComponent)
                try imageData.write(to: toURL, options: .atomic)
            } catch {
                print("Failed to write to disk: \(error)")
                return
            }
        }
        return true
    }
}

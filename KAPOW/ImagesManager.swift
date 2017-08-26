//
//  ImagesManager.swift
//  KAPOW
//
//  Created by Rustam on 8/26/17.
//  Copyright © 2017 Rustam Galiullin. All rights reserved.
//

import Cocoa

struct ImagesManager {
    
    private let bundleName = "/Images.bundle"
    private var images = [KapowImage]()
    
    init() {
        let fileManager = FileManager.default
        let imagePath = Bundle.main.resourcePath! + bundleName
        let imagePathURL = URL(string: imagePath)
        
        do {
            let paths = try fileManager.contentsOfDirectory(at: imagePathURL!, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: .skipsHiddenFiles)
            images = paths.map(KapowImage.init)
        } catch {
            assertionFailure("Can't find images in folder '\(bundleName)'")
        }
    }
    
    func randomImage() -> NSImage {
        let num = Int(arc4random_uniform(UInt32(images.count)))
        if images.indices.contains(num) {
            return images[num].image ?? NSImage()
        } else {
            assertionFailure("🤔🤔🤔🤔🤔🤔🤔🤔")
            return NSImage()
        }
    }
}

class KapowImage {
    private let path: URL
    
    private var _image: NSImage?
    var image: NSImage? {
        if _image == nil {
            _image = NSImage(contentsOf: path)
        }
        return _image
    }
    
    init(path: URL) {
        self.path = path
    }
}


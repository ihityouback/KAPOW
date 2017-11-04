//
//  AppDelegate.swift
//  KAPOW
//
//  Created by Rustam Galiullin on 03/09/16.
//  Copyright © 2016 Rustam Galiullin. All rights reserved.
//

import Cocoa
import MASShortcut
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var mainWindow: NSWindow?
    let images = ImagesManager()
    
    let startScale: CGFloat = 0.2
    let endScale: CGFloat = 4
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let window = NSApplication.shared.windows.first {
            mainWindow = window
            window.setFrame(NSRect(x: 0, y: 0, width: 0, height: 0), display: true, animate: false)
            window.isOpaque = false
            window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow)))
            window.collectionBehavior = NSWindow.CollectionBehavior.canJoinAllSpaces
        }
        
        configureShortcut()
    }
    
    func configureShortcut() {
        
        guard let shortcut =  MASShortcut(keyCode: UInt(kVK_ANSI_Q),
                                          modifierFlags: NSEvent.ModifierFlags.command.rawValue) else { return }
        
        let archivedKey = NSKeyedArchiver.archivedData(withRootObject: shortcut)
        UserDefaults.standard.setValue(archivedKey, forKey: "KAPOWShortcut")
    
        MASShortcutBinder.shared().bindShortcut(withDefaultsKey: "KAPOWShortcut", toAction: { [weak self] in
            self?.shot()
        })
    }
    
    func shot () {
        print("Shot!")
        
        guard let rect = NSScreen.main?.frame else { return }
        let window = NSWindow(contentRect: rect, styleMask: NSWindow.StyleMask.borderless, backing: NSWindow.BackingStoreType.buffered, defer: false)
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.alphaValue = 1
        window.makeKeyAndOrderFront(NSApplication.shared)
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow)))
        mainWindow?.addChildWindow(window, ordered: NSWindow.OrderingMode.above)
        
        let imageView = NSImageView(frame: window.frame)
        imageView.image = images.randomImage()
        imageView.wantsLayer = true
        window.contentView?.addSubview(imageView)
        
        imageView.frame = rect
        imageView.superview?.wantsLayer = true
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = startScale
        scaleAnimation.toValue = endScale

        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        
        let halfWidth = rect.size.width/2
        let xAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        xAnimation.fromValue = halfWidth - halfWidth * startScale
        xAnimation.toValue = halfWidth - halfWidth * endScale
        
        let halfHeight = rect.size.height/2
        let yAnimation = CABasicAnimation(keyPath: "transform.translation.y")
        yAnimation.fromValue = halfHeight - halfHeight * startScale
        yAnimation.toValue = halfHeight - halfHeight * endScale

        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.animations = [scaleAnimation, alphaAnimation, xAnimation, yAnimation]
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.mainWindow?.removeChildWindow(window)
        }
        imageView.layer?.add(animationGroup, forKey: "fullAnimation")
        CATransaction.commit()
    }
}

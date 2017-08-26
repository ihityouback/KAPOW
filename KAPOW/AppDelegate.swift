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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let window = NSApplication.shared().windows.first {
            mainWindow = window
            window.setFrame(NSRect(x: 0, y: 0, width: 0, height: 0), display: true, animate: false)
            window.isOpaque = false
            window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
            window.collectionBehavior = .canJoinAllSpaces
        }
        
        configureShortcut()
    }
    
    func configureShortcut() {
        
        guard let shortcut =  MASShortcut(keyCode: UInt(kVK_ANSI_A),
                                          modifierFlags: NSEventModifierFlags.command.rawValue) else { return }
        
        let archivedKey = NSKeyedArchiver.archivedData(withRootObject: shortcut)
        UserDefaults.standard.setValue(archivedKey, forKey: "KAPOWShortcut")
    
        MASShortcutBinder.shared().bindShortcut(withDefaultsKey: "KAPOWShortcut", toAction: { [weak self] in
            self?.shot()
        })
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {}
    
    func shot () {
        print("Shot!")
        
        let rect = NSScreen.main()?.frame
        let window = NSWindow(contentRect: rect!, styleMask: NSBorderlessWindowMask, backing: NSBackingStoreType.buffered, defer: false)
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.alphaValue = 1
        window.makeKeyAndOrderFront(NSApplication.shared())
        window.level = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
        mainWindow?.addChildWindow(window, ordered: NSWindowOrderingMode.above)
        
        let imageView = NSImageView(frame: window.frame)
        imageView.image = images.randomImage()
        imageView.wantsLayer = true
        window.contentView?.addSubview(imageView)
        
        imageView.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.2
        scaleAnimation.toValue = 5
        
        let alphaAnimation = CABasicAnimation(keyPath: "opacity")
        alphaAnimation.fromValue = 1
        alphaAnimation.toValue = 0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.animations = [scaleAnimation, alphaAnimation]
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.mainWindow?.removeChildWindow(window)
        }
        imageView.layer?.add(animationGroup, forKey: "fullAnimation")
        CATransaction.commit()
    }
}

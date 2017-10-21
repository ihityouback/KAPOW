//
//  TouchbarCanvas.swift
//  KAPOW
//
//  Created by Rustam on 8/26/17.
//  Copyright © 2017 Rustam Galiullin. All rights reserved.
//

import Cocoa

class ViewCanvas: NSView {
    
    let firstTextCanvas = TextCanvas()
    let secondTextCanvas = TextCanvas()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstTextCanvas.sizeToFit()
        secondTextCanvas.sizeToFit()
        
        self.addSubview(firstTextCanvas)
        self.addSubview(secondTextCanvas)
        
        secondTextCanvas.frame = updated(frame: firstTextCanvas.frame, with: firstTextCanvas.frame.width)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.start()
        }
    }
    
    var onAnimation = false
    func start() {
        if onAnimation { return }
        onAnimation = true
        
        NSAnimationContext.runAnimationGroup({ [unowned self] context in
            context.duration = 3
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            self.firstTextCanvas.animator().frame = self.updated(frame: self.firstTextCanvas.frame, with: -self.firstTextCanvas.frame.width)
            self.secondTextCanvas.animator().frame = self.updated(frame: self.secondTextCanvas.frame, with: 0)
            
        }) { [weak self] in
            guard let `self` = self else { return }
            self.onAnimation = false

            self.firstTextCanvas.animator().frame = self.updated(frame: self.firstTextCanvas.frame, with: 0)
            self.secondTextCanvas.animator().frame = self.updated(frame: self.firstTextCanvas.frame, with: self.firstTextCanvas.frame.width)
            DispatchQueue.main.async(execute: { 
                self.start()
            })
        }
    }
    
    func updated(frame: CGRect, with x: CGFloat) -> CGRect {
        var mFrame = frame
        mFrame.origin = CGPoint(x: x, y: frame.origin.y)
        return mFrame
    }
}

class TextCanvas: NSTextField {
    
    let text = "Ублюдок, мать твою, а ну иди сюда говно собачье, решил ко мне лезть? Ты, засранец вонючий, мать твою, а? Ну иди сюда, попробуй меня трахнуть, я тебя сам трахну ублюдок, онанист чертов, будь ты проклят, иди идиот, трахать тебя и всю семью, говно собачье, жлоб вонючий, дерьмо, сука, падла, иди сюда, мерзавец, негодяй, гад, иди сюда ты - говно, жопа!"
    
    init() {
        super.init(frame: NSRect.zero)
        config()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config() {
        self.stringValue = text
        self.textColor = .white
    }
    
    override func touchesBegan(with event: NSEvent) {
        
    }
}

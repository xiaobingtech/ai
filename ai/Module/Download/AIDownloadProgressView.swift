//
//  AIDownloadProgressView.swift
//  ai
//
//  Created by 范小兵 on 2024/5/5.
//

import UIKit

class AIDownloadProgressView: UIView {
    var progress: CGFloat = 0.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        UIColor.systemBlue.set()
        UIRectFill(.init(x: 0, y: 0, width: progress * rect.size.width, height: rect.size.height))
    }
}

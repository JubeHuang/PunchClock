//
//  ExpandTouchAreaButton.swift
//  PunchClock
//
//  Created by Jube on 2023/9/22.
//

import UIKit

class ExpandTouchAreaButton: UIButton {
    
    var touchEdgeInsets: UIEdgeInsets?
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var frame = self.bounds
        
        if let touchEdgeInsets = self.touchEdgeInsets {
            frame = frame.inset(by: touchEdgeInsets)
        }
        
        return frame.contains(point);
    }
}

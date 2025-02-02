//
//  DottedLineView.swift
//  PunchClock
//
//  Created by Jube on 2023/9/13.
//

import UIKit

class DashedLineView: UIView {
    override class var layerClass: AnyClass {
        return CAShapeLayer.self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let shapeLayer = self.layer as? CAShapeLayer {
            shapeLayer.strokeColor = UIColor.white70?.cgColor
            shapeLayer.lineWidth = 2.0
            shapeLayer.lineDashPattern = [1, 7]
            shapeLayer.lineCap = .round
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 0, y:  0))
            path.addLine(to: CGPoint(x: bounds.width, y: 0))
            
            shapeLayer.path = path.cgPath
        }
    }
}

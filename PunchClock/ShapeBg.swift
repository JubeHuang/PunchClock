//
//  shape.swift
//  RainbowDemo
//
//  Created by Jube on 2023/7/20.
//  Copyright © 2023 AppCoda. All rights reserved.
//

import UIKit

class ShapeBg: UIView {
    
    let startY: Int = 505
    let endY: Int = Int(UIScreen.main.bounds.size.height)
    let endX: Int = Int(UIScreen.main.bounds.size.width)
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let shapePath = UIBezierPath()
        shapePath.move(to: CGPoint(x: 0, y: endY))
        shapePath.addLine(to: CGPoint(x: 0, y: startY))
        shapePath.addQuadCurve(to: CGPoint(x: endX, y: startY), controlPoint: CGPoint(x: endX/2, y: 479))
        shapePath.addLine(to: CGPoint(x: endX, y: endY))
        shapePath.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = shapePath.cgPath
        shapeLayer.fillColor = UIColor.blue.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}


//
//  GraphingView.swift
//  Calculator
//
//  Created by Augusto on 12/23/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import UIKit


protocol GraphingViewDelegate: class {
    func needYAt(x: CGFloat) -> CGFloat
}

@IBDesignable class GraphingView: UIView {
    let axesDrawer = AxesDrawer()
    @IBInspectable var pointsPerUnit: CGFloat = 1 {
        didSet {
            UserDefaults.standard.set(Double(pointsPerUnit), forKey: "pointsPerUnit")
        }
    }
    var origin = CGPoint(x:UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midX) {
        didSet {
            UserDefaults.standard.set(Double(origin.x), forKey: "xOrigin")
            UserDefaults.standard.set(Double(origin.y), forKey: "yOrigin")
            
        }
    }
    weak var delegate: GraphingViewDelegate?
    
    func setup() {
        axesDrawer.contentScaleFactor = contentScaleFactor
        
        let defaults = UserDefaults.standard
        if let xOrigin = defaults.object(forKey: "xOrigin") as? Double,
            let yOrigin = defaults.object(forKey: "yOrigin") as? Double,
            let points = defaults.object(forKey: "pointsPerUnit") as? Double {
            origin = CGPoint(x: xOrigin, y: yOrigin)
            pointsPerUnit = CGFloat(points)
        } else {
            origin = CGPoint(x: bounds.width/2, y: bounds.height/2)
        }
        
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(GraphingView.rescale(_:)))
        addGestureRecognizer(pinchRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GraphingView.pan(_:)))
        addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GraphingView.recenterOrigin(_:)))
        tapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(tapRecognizer)
    }
    
    override func draw(_ rect: CGRect) {
        axesDrawer.drawAxesInRect(bounds: frame,
                                  origin: origin,
                                  pointsPerUnit: pointsPerUnit)
        drawFunction()
    }
    
    fileprivate func drawFunction() {
        let firstX = -origin.x / pointsPerUnit
        let lastX = frame.size.width / pointsPerUnit - origin.x / pointsPerUnit
        let step = (lastX - firstX) / frame.size.width
        var path = UIBezierPath()
        var moved = false
        
        for x in stride(from: firstX, to: lastX, by: step) {
            if let y = delegate?.needYAt(x: x) {
                if moved && (y.isZero || y.isNormal) {
                    path.addLine(to: convertToFrame(from: CGPoint(x: x, y: y)))
                } else if !moved && (y.isZero || y.isNormal) {
                    path.move(to: convertToFrame(from: CGPoint(x: x, y: y)))
                    moved = true
                } else if !y.isZero || !y.isNormal {
                    UIColor.blue.set()
                    path.lineWidth = 3.0
                    path.stroke()
                    path = UIBezierPath()
                    moved = false
                }
            }
        }
        
        UIColor.blue.set()
        path.lineWidth = 3.0
        path.stroke()
    }

    
    fileprivate func convertToView(x: CGFloat) -> CGFloat {
        return x / pointsPerUnit - origin.x / pointsPerUnit
    }
    
    fileprivate func convertToView(y: CGFloat) -> CGFloat {
        return -y / pointsPerUnit - origin.y / pointsPerUnit
    }
    
    
    fileprivate func convertToFrame(from point: CGPoint) -> CGPoint{
        let frameX = point.x * pointsPerUnit + origin.x
        let frameY = -point.y * pointsPerUnit + origin.y
        return CGPoint(x: frameX, y: frameY)
    }
    
    func rescale(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            pointsPerUnit *= gesture.scale
            gesture.scale = 1.0
            setNeedsDisplay()
        default:
            break
        }
    }
    
    func pan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed, .ended:
            let delta = gesture.translation(in: self)
            origin.x += delta.x
            origin.y += delta.y
            setNeedsDisplay()
            gesture.setTranslation(CGPoint.zero, in: self)
        default:
            break
        }
    }
    
    func recenterOrigin(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            origin = gesture.location(in: self)
            setNeedsDisplay()

        default:
            break
        }
    }

    
}

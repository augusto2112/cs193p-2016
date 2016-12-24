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

class GraphingView: UIView {
    let axesDrawer = AxesDrawer()
    private var pointsPerUnit: CGFloat = 1
    private var origin = CGPoint.zero
    weak var delegate: GraphingViewDelegate?
    
    func setup() {
        axesDrawer.contentScaleFactor = contentScaleFactor
        origin = CGPoint(x: frame.midX, y: frame.midY)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(GraphingView.rescale(_:)))
        addGestureRecognizer(pinchRecognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(GraphingView.pan(_:)))
        addGestureRecognizer(panRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(GraphingView.recenterOrigin(_:)))
        tapRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(tapRecognizer)
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        
        axesDrawer.drawAxesInRect(bounds: frame,
                                  origin: origin,
                                  pointsPerUnit: pointsPerUnit)
        drawFunction()
    }
    
    fileprivate func drawFunction() {
        let firstX = -origin.x / pointsPerUnit
        let lastX = frame.size.width / pointsPerUnit - origin.x / pointsPerUnit
        let step = (lastX - firstX) / frame.size.width
        
        let firstY = delegate?.needYAt(x: firstX) ?? 0.0
        let path = UIBezierPath()
        path.move(to: convertToFrame(from: CGPoint(x: firstX, y: firstY)))
        
        for x in stride(from: firstX + step, to: lastX, by: step) {
            let y = delegate?.needYAt(x: x) ?? 0.0
            path.addLine(to: convertToFrame(from: CGPoint(x: x, y: y)))
        }
        UIColor.blue.set()
        path.lineWidth = 1.0
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

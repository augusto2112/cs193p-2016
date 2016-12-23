//
//  GraphingView.swift
//  Calculator
//
//  Created by Augusto on 12/23/16.
//  Copyright © 2016 Nihil Games. All rights reserved.
//

import UIKit

class GraphingView: UIView {
    let axesDrawer = AxesDrawer()
    private var pointsPerUnit: CGFloat = 1
    private var origin = CGPoint.zero
    private var minPoint = 0.0
    func setup() {
        axesDrawer.contentScaleFactor = contentScaleFactor
        origin = CGPoint(x: frame.midX, y: frame.midY)
        minPoint = Double(frame.size.width - origin.y)
        print("points x axis = \(frame.size.width / pointsPerUnit)")
        
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
        print ("first point is = \(-origin.x / pointsPerUnit)")
        print("last point is \((frame.size.width / pointsPerUnit) - origin.x / pointsPerUnit)")

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

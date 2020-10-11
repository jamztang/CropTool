//
//  CanvasView.swift
//  CropTool
//
//  Created by James Tang on 11/10/2020.
//

import UIKit

struct Stroke {
    enum Operation {
        case union
        case substraction
    }
    var bezierPath: UIBezierPath
    var operation: Operation

    static func bezierPath(_ bezierPath: UIBezierPath, operation: Operation = .union) -> Stroke {
        let stroke = Stroke(bezierPath: bezierPath, operation: operation)
        return stroke
    }
}

class CanvasView: UIView {

    private var strokes: [Stroke] = []
    private var path: UIBezierPath?
    var operation: Stroke.Operation = .union

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Pens down

        guard let point = touches.first?.location(in: self) else {
            return
        }
        path = UIBezierPath()
        path?.move(to: point)
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Pens drawing

        guard let point = touches.first?.location(in: self), let path = path else {
            return
        }
        path.addLine(to: point)
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Pens up
        guard let point = touches.first?.location(in: self), let path = path else {
            return
        }
        path.addLine(to: point)
        path.close()
        self.path = nil
        strokes.append(.bezierPath(path, operation: operation))
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        // fill
        let fillColor = UIColor.white
        fillColor.setFill()
        UIRectFill(rect)

        // render strokes
        strokes.forEach { (stroke) in
            switch stroke.operation {
            case .substraction:
                // current stroke
                let strokeColor = UIColor.white
                strokeColor.setStroke()
                let path = stroke.bezierPath
                let fill = UIColor.white
                fill.setFill()
                path.fill()
                path.lineWidth = 1.0
                path.stroke()

            case .union:
                // current stroke
                let strokeColor = UIColor.black
                strokeColor.setStroke()
                let path = stroke.bezierPath
                let fill = UIColor.black
                fill.setFill()
                path.fill()
                path.lineWidth = 1.0
                path.stroke()
            }
        }

        // current stroke
        if let path = path {
            switch operation {
            case .union:
                let strokeColor = UIColor.blue
                strokeColor.setStroke()
                let fill = UIColor.blue.withAlphaComponent(0.5)
                fill.setFill()
            case .substraction:
                let strokeColor = UIColor.red
                strokeColor.setStroke()
                let fill = UIColor.red.withAlphaComponent(0.5)
                fill.setFill()
            }
            path.fill()
            path.lineWidth = 1.0
            path.stroke()
        }
    }

    func reset() {
        strokes.removeAll()
        setNeedsDisplay()
    }
}

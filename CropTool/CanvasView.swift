//
//  CanvasView.swift
//  CropTool
//
//  Created by James Tang on 11/10/2020.
//

import UIKit
import CoreGraphics

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

protocol CanvasViewDelegate: class {
    func canvasView(_ view: CanvasView, didCreate mask: UIImage, result: UIImage)
}

class CanvasView: UIView {

    private var strokes: [Stroke] = []
    private var path: UIBezierPath?
    private var isCreatingMask: Bool = false
    private var resultImage: UIImage?
    private var maskImage: UIImage?

    var operation: Stroke.Operation = .union
    var image: UIImage?
    weak var delegate: CanvasViewDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Pens down
        isCreatingMask = false
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
        getMask()
    }

    func getMask() {
        isCreatingMask = true
        guard let image = image else { return }
        let point = CGPoint(x: bounds.size.width / 2 - image.size.width / 2, y: bounds.size.height / 2 - image.size.height / 2)
        let scale = UIScreen.main.scale
        let cropRect = CGRect(origin: point, size: image.size).applying(.init(scaleX: scale, y: scale))

        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        layer.render(in: context)
        guard let renderedImage = UIGraphicsGetImageFromCurrentImageContext(), let cgimage = renderedImage.cgImage else { return }
        guard let croppedCGImage = cgimage.cropping(to: cropRect) else { return }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        maskImage = croppedImage
        let resultImage = getMaskImage(image: image, withMask: croppedImage)
        self.resultImage = resultImage
        delegate?.canvasView(self, didCreate: croppedImage, result: resultImage)
        isCreatingMask = false
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        // fill
        let fillColor = UIColor.white
        fillColor.setFill()
        UIRectFill(rect)

        // drawImage
        if !isCreatingMask {
            if let image = image {
                // Draw the input image
                let point = CGPoint(x: rect.size.width / 2 - image.size.width / 2, y: rect.size.height / 2 - image.size.height / 2)
                image.draw(at: point, blendMode: .normal, alpha: 0.3)
            }

            if let resultImage = resultImage {
                // Draw the result image
                let point = CGPoint(x: rect.size.width / 2 - resultImage.size.width / 2, y: rect.size.height / 2 - resultImage.size.height / 2)
                resultImage.draw(at: point)
            }
        } else {
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
        maskImage = nil
        isCreatingMask = false
        strokes.removeAll()
        setNeedsDisplay()
    }
}

private func getMaskImage(image: UIImage, withMask maskImage: UIImage) -> UIImage {

    let maskRef = maskImage.cgImage

    let mask = CGImage(
        maskWidth: maskRef!.width,
        height: maskRef!.height,
        bitsPerComponent: maskRef!.bitsPerComponent,
        bitsPerPixel: maskRef!.bitsPerPixel,
        bytesPerRow: maskRef!.bytesPerRow,
        provider: maskRef!.dataProvider!,
        decode: nil,
        shouldInterpolate: false)

    let masked = image.cgImage!.masking(mask!)
    let maskedImage = UIImage(cgImage: masked!)

    // No need to release. Core Foundation objects are automatically memory managed.

    return maskedImage

}

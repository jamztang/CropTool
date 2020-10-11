//
//  ViewController.swift
//  CropTool
//
//  Created by James Tang on 11/10/2020.
//

import UIKit

enum Mode: Int {
    case add = 0
    case substract = 1
}

class ViewController: UIViewController {

    @IBOutlet private weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var resetButton: UIButton!

    private let canvasView = CanvasView(frame: .zero)
    @IBOutlet weak var maskView: UIImageView!
    @IBOutlet weak var previewView: UIImageView!
    private var image: UIImage = UIImage(named: "baby") ?? UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.view.insertSubview(canvasView, at: 0)
        canvasView.frame = view.bounds
        canvasView.image = image
        canvasView.isUserInteractionEnabled = true
        canvasView.delegate = self
        canvasView.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleRightMargin, .flexibleLeftMargin]
    }

    @IBAction func resetButtonDidPress(_ sender: Any) {
        Swift.print("TTT reset")
        canvasView.reset()
    }

    @IBAction func segmentedControlDidChange(_ sender: Any) {

        guard let mode = Mode(rawValue: modeSegmentedControl.selectedSegmentIndex) else {
            return
        }
        switch mode {
        case .add:
            canvasView.operation = .union
            break
        case .substract:
            canvasView.operation = .substraction
            break
        }
    }
}

extension ViewController: CanvasViewDelegate {
    func canvasView(_ view: CanvasView, didCreate mask: UIImage, result: UIImage) {
        maskView.image = mask
        previewView.image = result
    }
}

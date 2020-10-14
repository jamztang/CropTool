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
    @IBOutlet private weak var selectButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet private weak var canvasView: CanvasView!

    @IBOutlet weak var maskView: UIImageView!
    @IBOutlet weak var previewView: UIImageView!
    private var image: UIImage? {
        didSet {
            canvasView.setImage(image, resize: true)
            canvasView.reset()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        canvasView.frame = view.bounds
        canvasView.isUserInteractionEnabled = true
        canvasView.delegate = self

        image = UIImage(named: "baby")
    }

    @IBAction func resetButtonDidPress(_ sender: Any) {
        Swift.print("TTT reset")
        canvasView.reset()
    }

    @IBAction func selectButtonDidPress(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    @IBAction func saveButtonDidPress(_ sender: Any) {
        if let image = previewView.image {
            let activityController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            if let popover = activityController.popoverPresentationController, let sender = sender as? UIView {
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
            }
            present(activityController, animated: true)
        }
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

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Swift.print("TTT didFinishPickingMediaWithInfo \(info)")

        picker.dismiss(animated: true, completion: nil)
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else { return }
        self.image = image
    }
}

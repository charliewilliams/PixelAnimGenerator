//
//  ViewController.swift
//  PixelAnimGenerator
//
//  Created by Charlie Williams on 20/06/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

class ViewController: UIViewController {

    enum InputType: Int {
        case pen // touch writes pixels at the touch location, width from touch size slider (autofading)
        case fade // touch Y location controls momentary brightness across all pixels
        case pro // 2-touch writes pixels at the touches' centre; width controlled by distance between touches
    }

    @IBOutlet weak var generatedImageView: UIImageView!
    @IBOutlet weak var inputTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var touchSizeSlider: UISlider!
    @IBOutlet weak var currentTouchSizeLabel: UILabel!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var startStopButton: UIButton!

    let pixelHeight = 12
    var touchStepIncrement: CGFloat {
        return 255.0 / CGFloat(pixelHeight)
    }
    var blankFrame: [CGFloat] {
        return [CGFloat](repeating: 0, count: self.pixelHeight)
    }

    var running = false {
        didSet {

            runTimer?.invalidate()

            startStopButton.setTitle(running ? "Stop" : "Ready", for: .normal)

            if running {

                runTimer = Timer.scheduledTimer(timeInterval: 1/30.0, target: self, selector: #selector(runTimerFired), userInfo: nil, repeats: true)

            } else {

                runTimer = nil

                // ask to save
                let sheet = UIAlertController(title: "Save image to photos?", message: nil, preferredStyle: .actionSheet)
                sheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in

                    if let image = self.generatedImageView.image {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    self.reset()
                }))

                sheet.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
                    self.reset()
                }))

                sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    self.running = true
                }))

                present(sheet, animated: true, completion: nil)
            }
        }
    }
    var color: UIColor = .white {
        didSet {
            colorSwatch.backgroundColor = color
        }
    }
    @IBOutlet weak var colorSwatch: UIView!

    var touchSize: Int = 1
    var inputType: InputType = .pen
    var runTimer: Timer?
    var frames = [[CGFloat]]()
    var touchY: Int?

    func reset() {

        frames.removeAll()
        generatedImageView.image = nil
    }

    @IBAction func startButtonPressed(_ sender: UIButton) {
        running = !running
    }

    @objc func runTimerFired() {

        // write pixels according to touch location
        if let touchY = touchY {

            frames.append(frameFor(touchY))

        } else {
            frames.append(blankFrame)
        }

        // update display image

    }

    func frameFor(_ touchY: Int) -> [CGFloat] {

        switch inputType {

        case .pen, .pro:
            return []

        case .fade:
            return [CGFloat](repeating: CGFloat(touchY) * touchStepIncrement, count: pixelHeight)
        }
    }

    @IBAction func touchSizeSliderChanged(_ sender: UISlider) {
        touchSize = Int(sender.value)
        currentTouchSizeLabel.text = "\(touchSize)"
    }

    @IBAction func inputTypeControlChanged(_ sender: UISegmentedControl) {
        inputType = InputType(rawValue: sender.selectedSegmentIndex)!
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouches(touches)
    }

    func handleTouches(_ touches: Set<UITouch>) {

        guard let first = touches.first,
            touchView.frame.contains(first.location(in: touchView)) else {
                return
        }

        let numPixels = CGFloat(self.pixelHeight)

        if inputType == .pro,
            let first = touches.first,
            let second = touches.dropFirst().first {

            // get distance
            let loc1 = first.location(in: touchView)
            let loc2 = second.location(in: touchView)
            let dist = hypot(loc1.x - loc2.x, loc1.y - loc2.y)
            let normDist = min(dist / (touchView.bounds.height * 0.8), 1)
            touchSize = Int(normDist * numPixels)

            // get centre
            let mid = fabs(loc1.y - loc2.y)/2 + min(loc1.y, loc2.y)
            touchY = Int(mid / touchView.bounds.height * numPixels)

        } else {

            let location = first.location(in: touchView)
            touchY = Int(location.y / touchView.bounds.height * numPixels)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchY = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchY = nil
    }

    @objc func colorDidChange(to newColor: UIColor) {

        color = newColor
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let pickerVC = segue.destination as? ColorPickerViewController else {
            return
        }

        pickerVC.initialColor = color
    }
}


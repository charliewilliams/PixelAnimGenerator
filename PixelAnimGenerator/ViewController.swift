//
//  ViewController.swift
//  PixelAnimGenerator
//
//  Created by Charlie Williams on 20/06/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import UIKit
import SwiftHSVColorPicker

let defaultColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)

class ViewController: UIViewController {

    enum InputType: Int {
        case pen // touch writes pixels at the touch location, width from touch size slider (autofading)
        case fade // touch Y location controls momentary brightness across all pixels
        case pro // 2-touch writes pixels at the touches' centre; width controlled by distance between touches
        case multi // multiple touches of set width, pressure = brightness & width offset
    }

    @IBOutlet weak var generatedImageView: UIImageView!
    @IBOutlet weak var inputTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var touchSizeSlider: UISlider!
    @IBOutlet weak var currentTouchSizeLabel: UILabel!
    @IBOutlet weak var touchView: UIView!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var recordSpeedSegmentedControl: UISegmentedControl!

    let pixelHeight = 12
    var touchStepIncrement: CGFloat {
        return 255.0 / CGFloat(pixelHeight)
    }
    var blankFrame: [CGFloat] {
        return [CGFloat](repeating: 0, count: self.pixelHeight)
    }
    var recordingTimeInterval: TimeInterval {
        let divisor = [1, 0.5, 0.25, 0.125][recordSpeedSegmentedControl.selectedSegmentIndex]
        let baseFrameRate = 1/30.0
        return baseFrameRate / divisor
    }

    var running = false {
        didSet {

            runTimer?.invalidate()

            startStopButton.setTitle(running ? "Stop" : "Ready", for: .normal)

            if running {

                runTimer = Timer.scheduledTimer(timeInterval: recordingTimeInterval, target: self, selector: #selector(runTimerFired), userInfo: nil, repeats: true)

            } else {

                runTimer = nil

                let image = generatedImageView.image

                // ask to save
                let sheet = UIAlertController(title: "Save image to photos?", message: nil, preferredStyle: .actionSheet)
                sheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in

                    if let image = image {
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
    var color: UIColor! {
        didSet {
            colorSwatch.backgroundColor = color

            colorTable.removeAll()

            var h: CGFloat = 0
            var s: CGFloat = 0
            var b: CGFloat = 0
            color.getHue(&h, saturation: &s, brightness: &b, alpha: nil)

            for i in 0..<256 {
                let brightness = b * (CGFloat(i) / 255.0)
                colorTable.append(UIColor(hue: h, saturation: s, brightness: brightness, alpha: 1))
            }
        }
    }
    var colorTable = [UIColor]()

    @IBOutlet weak var colorSwatch: UIView!

    var touchSize: Int = 1
    var inputType: InputType = .pen
    var runTimer: Timer?
    var frames = [[CGFloat]]()
    var touchY: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

        color = defaultColor
    }

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
        generatedImageView.image = imageFromCurrentFrames()
    }

    let onePixelSize = CGSize(width: 1, height: 1)

    func imageFromCurrentFrames() -> UIImage? {

        UIGraphicsBeginImageContext(CGSize(width: frames.count, height: pixelHeight))
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        for (x, frame) in frames.enumerated() {

            for (y, pixel) in frame.enumerated() {
                context.setFillColor(colorTable[Int(pixel)].cgColor)
                context.addRect(CGRect(origin: CGPoint(x: x, y: y), size: onePixelSize))
                context.drawPath(using: .fill)
            }
        }

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }

    func frameFor(_ touchY: Int) -> [CGFloat] {

        switch inputType {

        case .pen, .pro:

            var frame = [CGFloat]()

            for i in 0..<pixelHeight {
                let distanceFromTouch = abs(touchY - i)
                if distanceFromTouch > touchSize {
                    frame.append(0)
                }
                frame.append(distanceFromTouch.lerp(from: 0, to: touchSize, min: 0, max: 255))
            }

            return frame

        case .fade:
            return [CGFloat](repeating: CGFloat(touchY) * touchStepIncrement, count: pixelHeight)

        case .multi:
            return [] // todo
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
            touchView.bounds.contains(first.location(in: touchView)) else {
                return
        }

        if !running {
            running = true
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

        } else if inputType == .multi {

            for touch in touches {

                let normalizedForce = touch.force / touch.maximumPossibleForce
                // todo use force to expand size
                print(normalizedForce)
            }

        } else {

            let location = first.location(in: touchView)
            touchY = Int(numPixels - location.y / touchView.bounds.height * numPixels)
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


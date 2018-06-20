//
//  ColorPickerViewController.swift
//  PixelAnimGenerator
//
//  Created by Charlie Williams on 20/06/2018.
//  Copyright © 2018 Charlie Williams. All rights reserved.
//

import SwiftHSVColorPicker

class ColorPickerViewController: UIViewController {

    var initialColor: UIColor?
    @IBOutlet weak var picker: SwiftHSVColorPicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.setViewColor(initialColor ?? .white)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let root = parent?.childViewControllers.first as? ViewController {
            root.color = picker.color
        }
    }
}

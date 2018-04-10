//
//  ViewController.swift
//  ColorMarkerWithSlider
//
//  Created by Jayahari Vavachan on 4/9/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var displayView: UIView!
    enum Slider: Int { case red = 0, green, blue};
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func sliderValueChanged(_ sender: UISlider) {
        displayView.backgroundColor = UIColor(displayP3Red: CGFloat(redSlider.value), green:  CGFloat(greenSlider.value), blue:  CGFloat(blueSlider.value), alpha: 1.0)
    }

}


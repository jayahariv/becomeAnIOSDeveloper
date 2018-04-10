//
//  ResultsViewController.swift
//  RockPaperScissors
//
//  Created by Jayahari Vavachan on 4/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    var computerValue: HomeViewController.PlayState!
    var userValue: HomeViewController.PlayState!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch computerValue {
        case .rock:
            switch userValue {
            case .rock:
                imageView.image = UIImage(named: "itsATie")
            case .scissors:
                imageView.image = UIImage(named: "RockCrushesScissors")
            default:
                imageView.image = UIImage(named: "PaperCoversRock")
            }
        case .scissors:
            switch userValue {
            case .rock:
                imageView.image = UIImage(named: "RockCrushesScissors")
            case .scissors:
                imageView.image = UIImage(named: "itsATie")
            default:
                imageView.image = UIImage(named: "ScissorsCutPaper")
            }
        default:
            switch userValue {
            case .rock:
                imageView.image = UIImage(named: "PaperCoversRock")
            case .scissors:
                imageView.image = UIImage(named: "ScissorsCutPaper")
            default:
                imageView.image = UIImage(named: "itsATie")
            }
        }
    }
    
    @IBAction func onPlayAgain(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

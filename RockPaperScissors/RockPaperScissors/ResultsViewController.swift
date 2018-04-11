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
    @IBOutlet weak var winnerLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("com: \(computerValue) user: \(userValue)")
        if computerValue == userValue {
            imageView.image = UIImage(named: "itsATie")
            winnerLabel.text = "Its a Tie!!"
        } else if (computerValue == .rock && userValue == .paper) || (computerValue == .paper && userValue == .rock) {
            imageView.image = UIImage(named: "PaperCoversRock")
            winnerLabel.text = "Paper covers Rock. You " + (userValue == .paper ? "Win" : "Loose") + "!!"
        } else if (computerValue == .rock && userValue == .scissors) || (computerValue == .scissors && userValue == .rock) {
            imageView.image = UIImage(named: "RockCrushesScissors")
            winnerLabel.text = "Rock crushes Scissors. You " + (userValue == .rock ? "Win" : "Loose") + "!!"
        } else if (computerValue == .scissors && userValue == .paper) || (computerValue == .paper && userValue == .scissors) {
            imageView.image = UIImage(named: "ScissorsCutPaper")
            winnerLabel.text = "Scissors cut Paper. You " + (userValue == .scissors ? "Win" : "Loose") + "!!"
        }
    }
    
    @IBAction func onPlayAgain(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

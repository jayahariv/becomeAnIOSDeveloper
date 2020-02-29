//
//  HomeViewController.swift
//  RockPaperScissors
//
//  Created by Jayahari Vavachan on 4/10/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    enum ButtonType: Int { case paper = 0, rock, scissors }
    enum SegueFrom: String { case rock = "rockSegue", scissors = "scissorsSegue" }
    enum PlayState: Int { case paper = 1, rock, scissors }
    override func viewDidLoad() {
        super.viewDidLoad()
        print(randomValue())
    }
    
    func randomValue() -> Int {
        return Int(arc4random() % 3) + 1
    }
    

    @IBAction func onPlay(_ sender: UIButton) {
        if ButtonType(rawValue: sender.tag)! == .paper {
            // code
            let vc = storyboard?.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
            vc.userValue = PlayState.paper
            vc.computerValue = PlayState(rawValue: randomValue())
            present(vc, animated: true, completion: nil)
        } else if ButtonType(rawValue: sender.tag)! == .rock {
            // segue + code
            performSegue(withIdentifier: "rockSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ResultsViewController
        vc.computerValue = PlayState(rawValue: randomValue())
        switch SegueFrom(rawValue: segue.identifier!)! {
            case .rock:
            vc.userValue = PlayState.rock
            case .scissors:
            vc.userValue = PlayState.scissors
        }
    }
}


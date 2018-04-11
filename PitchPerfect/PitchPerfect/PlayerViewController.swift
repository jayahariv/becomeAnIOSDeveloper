//
//  PlayerViewController.swift
//  PitchPerfect
//
//  Created by Jayahari Vavachan on 4/8/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {

    // MARK: properties
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var highPitch: UIButton!
    @IBOutlet weak var lowPitch: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    var recordedAudioURL: URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    // MARK: Button types raw values corresponds to different buttons tags.
    enum PlayButton: Int { case slow = 0, fast, highPitch, lowPitch, echo, reverb}
    
    // MARK: UI methods
    func configureUI(_ playState: PlayingState, _ sender: UIButton? = nil) {
        switch(playState) {
        case .playing:
            updateUI(isPlaying: true)
            sender?.addGlow()
        case .notPlaying:
            updateUI(isPlaying: false)
            removeAllGlow()
        }
    }
    
    func setupUI() {
        slowButton.imageView?.contentMode = .scaleAspectFit
        highPitch.imageView?.contentMode = .scaleAspectFit
        fastButton.imageView?.contentMode = .scaleAspectFit
        lowPitch.imageView?.contentMode = .scaleAspectFit
        echoButton.imageView?.contentMode = .scaleAspectFit
        reverbButton.imageView?.contentMode = .scaleAspectFit
    }
    
    func updateUI(isPlaying: Bool) {
        setPlayButtonsEnabled(!isPlaying)
        stopButton.isEnabled = isPlaying
    }
    
    func removeAllGlow() {
        slowButton.removeGlow()
        highPitch.removeGlow()
        fastButton.removeGlow()
        lowPitch.removeGlow()
        echoButton.removeGlow()
        reverbButton.removeGlow()
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        slowButton.isEnabled = enabled
        highPitch.isEnabled = enabled
        fastButton.isEnabled = enabled
        lowPitch.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }
    
    // MARK: Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
        configureUI(.notPlaying)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }

    // MARK: button actions
    @IBAction func onRecordNewSound(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPlaySound(_ sender: UIButton) {
        switch PlayButton(rawValue: sender.tag)! {
            case .slow:
                playSound(rate: 0.5)
            case .fast:
                playSound(rate: 1.5)
            case .highPitch:
                playSound(pitch: 1000)
            case .lowPitch:
                playSound(pitch: -1000)
            case .echo:
                playSound(echo: true)
            case .reverb:
                playSound(reverb: true)
        }
        configureUI(.playing, sender)
    }
    
    @IBAction func onStopButtonPressed(_ sender: Any?) {
        stopAudio()
    }
}

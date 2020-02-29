//
//  RecordViewController.swift
//  PitchPerfect
//
//  Created by Jayahari Vavachan on 4/8/18.
//  Copyright © 2018 JayahariV. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController {

    // MARK: properties
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var circle3: UIView!
    @IBOutlet weak var tapToRecordLabel: UILabel!
    
    var audioRecorder: AVAudioRecorder!
    enum SegueTo: String { case player = "RecordToPlayerSegue"}
    
    // MARK: view helpers
    func setupView() {
        recordButton.makeCircle()
        recordButton.setImage(UIImage(named: "microphone"), for: .normal)
        recordButton.setImage(UIImage(named: "stop"), for: .selected)
        
        // setup circles
        circle1.circleSetup()
        circle2.circleSetup()
        circle3.circleSetup()
    }
    
    func recordingAnimation() {
        circle1.fadeOut(after: 0.5)
        circle2.fadeOut(after: 0.7)
        circle3.fadeOut(after: 1.0)
    }
    
    func recordingStoppedAnimation() {
        circle1.stopAnimate()
        circle2.stopAnimate()
        circle3.stopAnimate()
    }
    
    func setupUI(isRecoding: Bool) {
        tapToRecordLabel.text = isRecoding ? "Tap to finish recoding" : "Tap to start recoding"
        if isRecoding {
            recordingAnimation()
        } else {
            recordingStoppedAnimation()
        }
    }
    
    // MARK: lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
   
    // MARK: button actions
    @IBAction func onRecord(_ sender: UIButton) {
        recordButton.isSelected = !recordButton.isSelected
        setupUI(isRecoding: recordButton.isSelected)
        if recordButton.isSelected {
            // filepath
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let recordingName = "recodedVoice.wav"
            let pathArray = [dirPath, recordingName]
            let filePath = URL(string: pathArray.joined(separator: "/"))
            
            // configure the session
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            
            // record
            try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } else {
            audioRecorder.stop()
            let session = AVAudioSession.sharedInstance()
            try! session.setActive(false)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch SegueTo(rawValue: segue.identifier!)! {
        case .player:
            let vc = segue.destination as! PlayerViewController
            vc.recordedAudioURL = sender as! URL
        }
    }
}

extension RecordViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        performSegue(withIdentifier: SegueTo.player.rawValue, sender: recorder.url)
    }
}

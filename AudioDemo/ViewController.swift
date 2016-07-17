//
//  ViewController.swift
//  AudioDemo
//
//  Created by Tatsuhiko Arai on 7/17/16.
//  Copyright © 2016 Tatsuhiko Arai. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer?
    var outputFileURL: NSURL!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Disable Stop/Play button when application launches
        playButton.enabled = false
        stopButton.enabled = false

        // Set the audio file
        let path = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        let pathComponents = NSArray(objects: path, "MyAudioMemo.m4a")
        outputFileURL = NSURL.fileURLWithPathComponents(pathComponents as! [String])!

        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)

        // Define the recorder setting
        let recordSettings = [
            AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVSampleRateKey: NSNumber(float: 8000.0),
            AVNumberOfChannelsKey: NSNumber(int: 2)
        ]

        // Initiate and prepare the recorder
        recorder = try! AVAudioRecorder(URL: outputFileURL, settings: recordSettings)
        recorder.delegate = self
        recorder.meteringEnabled = true
        recorder.prepareToRecord()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordPauseTapped(sender: AnyObject) {
        // Stop the audio player before recording
        if let player = player where player.playing {
            player.stop()
        }

        if !recorder.recording {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(true)

                // Start recording
                recorder.record()
                recordButton.setTitle("Pause", forState: .Normal)
            } catch {
                print(error)
            }
        } else {
            // Pause recording
            recorder.pause()
            recordButton.setTitle("Record", forState: .Normal)
        }
        stopButton.enabled = true
        playButton.enabled = false
    }

    @IBAction func playTapped(sender: AnyObject) {
        if !recorder.recording {
            do {
                player = try AVAudioPlayer(contentsOfURL: recorder.url)
                player!.delegate = self
                player!.play()
            } catch {
                print(error)
            }
        }
    }

    @IBAction func stopTapped(sender: AnyObject) {
        recorder.stop()

        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(false)
            // Call remoteSize variable on a thread different from main thread. It's a quite botch.
            let controller = UIAlertController(title: "Done", message: "Finish recording! Size: \(outputFileURL.remoteSize)", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            controller.addAction(okAction)
            presentViewController(controller, animated: true, completion: nil)
        } catch {
            print(error)
        }
    }

    // MARK: -- AVAudioRecorderDelegate methods

    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        recordButton.setTitle("Record", forState: .Normal)

        stopButton.enabled = false
        playButton.enabled = true
    }

    // NARK: -- AVAudioPlayerDelegate methods

    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        let controller = UIAlertController(title: "Done", message: "Finish playing the recording!", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        controller.addAction(okAction)
        presentViewController(controller, animated: true, completion: nil)
    }
}

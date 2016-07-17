//
//  ViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/10/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import AVFoundation

class BabelPetViewController: UIViewController, AVAudioRecorderDelegate,
    AVAudioPlayerDelegate
{
    // MARK: Local Variables
    var currentRecording = 1
    var translations = [PetTranslation]()
    var curTrans: PetTranslation!
    var audioPath: String!
    var audioURL: NSURL!
    let audioSettings =
    [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    // MARK: Properties
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var translationTextBox: UITextView!

    
    // MARK: Convenience Functions
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: Audio Engine
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    // MARK: Actions
    @IBAction func startTranslationAction(sender: UITapGestureRecognizer)
    {
        /* If we are in the middle of the recording, clean it up */
        if audioRecorder != nil
        {
            cleanUpRecording(success: true)
            print("Recording finished without issue")
            return
        }
        
        /* Otherwise we are a new recording */
        audioPath = getDocumentsDirectory().stringByAppendingString("/petBabel\(currentRecording).m4a")
        currentRecording += 1
        audioURL = NSURL(fileURLWithPath: audioPath)
        curTrans = PetTranslation(audioURL: audioURL)
        
        do
        {
            
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: audioSettings)
            audioRecorder.delegate = self
            
            if !audioRecorder.record()
            {
                print("Recording failed to start")
                return
            }
            
            statusLabel.text = "Recording..."
            print("Recording started")
            
        }
        catch
        {
            print("Failure trying to make Audio Recorder")
            cleanUpRecording(success: false)
        }

    }
    
    
    @IBAction func startPlaybackAction(sender: UITapGestureRecognizer)
    {
        print("Playback started")
        statusLabel.text = "Playing sound"
    }
    
    func startPlayback()
    {
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOfURL: curTrans.audioURL!)
            audioPlayer = originalVoice
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            print("Playback failed")
        }
    }

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /* We need the user to grant permission to use the microphone */
        recordingSession = AVAudioSession.sharedInstance()
        
        do
        {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue())
                {
                    if allowed
                    {
                        print("Recording granted")
                    } else
                    {
                        print("Permisison for microphone denied")
                    }
                }
            }
        } catch
        {
           print("Failed to get permissions for recording")
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: AVAudioRecorderDelegate
    func cleanUpRecording(success success: Bool)
    {
        if audioRecorder != nil
        {
            audioRecorder.stop()
        }
        
        audioRecorder = nil
        
        if(success)
        {
            statusLabel.text = "Recording Finished Sucessfully"
            translationTextBox.text = curTrans.translatedText
            startPlayback()
        }
        else
        {
            statusLabel.text = "Recording Failed!"
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            print("Audio did not finish recording!")
            cleanUpRecording(success: false)
        }
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool)
    {
        statusLabel.text = "Playback finished!"
        
        if flag
        {
            print("Playback finished!")
        }
        else
        {
            print("Error with playback")
        }
    }
}


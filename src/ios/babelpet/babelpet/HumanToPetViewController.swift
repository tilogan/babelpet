//
//  HumanToPetViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/23/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import AVFoundation

class HumanToPetViewController: UIViewController, AVAudioRecorderDelegate,
    AVAudioPlayerDelegate, UIPickerViewDelegate
{

    //MARK: Properties
    @IBOutlet weak var animalPicker: UIPickerView!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: Local Variables
    var audioPath: String!
    var audioURL: NSURL!
    var curOriginalURL: NSURL!
    
    // MARK: Audio Engine
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    let audioSettings =
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    func startPlayback()
    {
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOfURL: curOriginalURL)
            audioPlayer = originalVoice
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            print("Playback failed")
            playButton.enabled = true
        }
    }
    
    // MARK: Functions
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func cleanUpRecording(success success: Bool)
    {
        if audioRecorder != nil
        {
            audioRecorder.stop()
        }
        
        audioRecorder = nil
        
        if(success)
        {
            startPlayback()
        }
        else
        {
            print("Failed recording!")
            playButton.enabled = true
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        do
        {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func recordPressed(sender: UIButton)
    {
        /* If we are in the middle of the recording, clean it up */
        if audioRecorder != nil
        {
            curOriginalURL = audioRecorder.url
            cleanUpRecording(success: true)
            print("Recording finished without issue")
            return
        }
        
        /* Otherwise we are a new recording */
        audioPath = getDocumentsDirectory().stringByAppendingString("/petBabelHuman.m4a")
        audioURL = NSURL(fileURLWithPath: audioPath)
        
        do
        {
            
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: audioSettings)
            audioRecorder.delegate = self
            
            if !audioRecorder.record()
            {
                print("Recording failed to start...")
                return
            }
            
            playButton.enabled = false
            print("Recording started...")
            
        }
        catch
        {
            print("Failure trying to make Audio Recorder!")
            cleanUpRecording(success: false)
        }
        
    }
    
    @IBAction func playPressed(sender: UIButton)
    {
        
    }
    
    // MARK: AVAudioRecorderDelegate
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
        playButton.enabled = true
        
        if flag
        {
            print("Playback finished!")
        }
        else
        {
            print("Error with playback")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

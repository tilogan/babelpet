//
//  HumanToPetViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/23/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import AVFoundation

enum Animal: Int, CustomStringConvertible
{
    case WesternDog = 0
    case 日本Dog = 1
    
    static var count: Int { return Language.日本語.hashValue + 1}
    
    var description: String
    {
        switch self
        {
        case .WesternDog: return "Western Dog"
        case .日本Dog   : return "日本 (Japanese) Dog"
        }
    }
}

enum Gender: Int, CustomStringConvertible
{
    case Male = 0
    case Female = 1
    
    static var count: Int { return Language.日本語.hashValue + 1}
    
    var description: String
    {
        switch self
        {
        case .Male: return "Male"
        case .Female   : return "Female"
        }
    }
}

class HumanToPetViewController: UIViewController, AVAudioRecorderDelegate,
    AVAudioPlayerDelegate, UIPickerViewDelegate
{

    //MARK: Properties
    @IBOutlet weak var animalPicker: UIPickerView!
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: Local Variables
    var audioURL: NSURL!
    var curOriginalURL: NSURL!
    var curTranslatedURL: NSURL!
    var referencedController: MainMenuViewController!
    var audioRecorder: AVAudioRecorder!
    var curPower = Float(0)
    let powerThreshold = Float(-20.0)
    var curRecordingLength = Double(0)
    var curAnimal: Animal! = .WesternDog
    var curGender: Gender! = .Male
    var bufferList = [AVAudioPCMBuffer]()
    var completionInt = 0
    
    var audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    
    // MARK: Functions
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func audioBufferCallBack()
    {
        if !bufferList.isEmpty
        {
            let curIndex = Int(arc4random_uniform(UInt32(bufferList.count)))
                playerNode.scheduleBuffer(bufferList[curIndex], completionHandler: audioBufferCallBack)
                bufferList.removeAtIndex(curIndex)
                playerNode.play()
        }
        else
        {
            completionInt = 1
        }
    }
    
    func translateIntoPet()
    {
        var audioFile: AVAudioFile!
        let numberOfSegments: UInt32 = 10
        bufferList = [AVAudioPCMBuffer]()
        
        do
        {
            try audioFile = AVAudioFile(forReading: curOriginalURL)
        }
        catch
        {
            print("HumanToPet: ERROR - Could not create audio file")
            return
        }
        
        let frameCount = UInt32(audioFile.length)
        let framesPerSegment = frameCount / numberOfSegments
        audioFile.framePosition = 0
        
        do
        {
            for framePos in 0...(numberOfSegments-1)
            {
                audioFile.framePosition = Int64(framesPerSegment * framePos)
                let curBuffer = AVAudioPCMBuffer(PCMFormat: audioFile.processingFormat,
                                                frameCapacity: framesPerSegment)
                try audioFile.readIntoBuffer(curBuffer)
                try audioFile.readIntoBuffer(curBuffer)
                bufferList.append(curBuffer)

            }
        }
        catch
        {
            print("HumanToPet: Translation failed!")
        }
        
        let format = AVAudioFormat(commonFormat: bufferList[0].format.commonFormat,
                                   sampleRate: bufferList[0].format.sampleRate,
                                   channels: bufferList[0].format.channelCount,
                                   interleaved: bufferList[0].format.interleaved);
        audioEngine.connect(playerNode, to: audioEngine.outputNode, format: format)
        
      
        let curIndex = Int(arc4random_uniform(UInt32(bufferList.count)))
        playerNode.scheduleBuffer(bufferList[curIndex], completionHandler: audioBufferCallBack)
        bufferList.removeAtIndex(curIndex)
       
        do
        {
            try audioEngine.start()
            completionInt = 0
            playerNode.play()
        }
        catch
        {
            print("HumanToPet: Error starting audio engine")
        }
        
        while(completionInt == 0)
        {
            
        }
        
        recordButton.setTitle("Press to Record", forState: .Normal)
    
    }
    
    /* Cleans up the recording */
    func cleanUpRecording(success success: Bool)
    {
        if audioRecorder != nil
        {
            audioRecorder.stop()
        }
        
        audioRecorder = nil
        
        /* Checking to make sure recorder actually picked something up */
        if curPower < powerThreshold
        {
            print("HumanToPet: Power failed to fall within volume threshold")
            statusLabel.text = "I can't hear you! Speak up!"
            playButton.enabled = false
            recordButton.setTitle("Press to Record", forState: .Normal)
            return
        }
        
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOfURL: audioURL)
            print("HumanToPet: Duration is \(originalVoice.duration)")
            
            if originalVoice.duration < 1.5
            {
                print("HumanToPet: ERROR - duration not long enough!")
                statusLabel.text = "What was that?! Speak longer!"
                playButton.enabled = false
                recordButton.setTitle("Press to Record", forState: .Normal)
                return
            }
            
            translateIntoPet()
            
        }
        catch
        {
            print("HumanToPet: ERROR - Could not initialize playback")
        }
    
        if(success)
        {
            statusLabel.text = "I hear ya! Here is the translation!"
        }
        else
        {
            print("HumanToPet: ERROR - Failed recording!")
            playButton.enabled = false
        }

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        recordButton.setTitle("Press to Record", forState: .Normal)
        genderPicker.delegate = self
        animalPicker.delegate = self
        audioEngine.attachNode(playerNode)
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
            /* Updating the meter and discarding any recording which is too
             quiet */
            audioRecorder.updateMeters()
            curPower = audioRecorder.peakPowerForChannel(0)
            print("HumanToPet: Peak power is \(curPower)")
            
            curOriginalURL = audioRecorder.url
            cleanUpRecording(success: true)
            print("HumanToPet: Recording finished without issue")
            return
        }
        
        /* Otherwise we are a new recording */
        let audioPath = getDocumentsDirectory().stringByAppendingString("/petBabelHuman.m4a")
        audioURL = NSURL(fileURLWithPath: audioPath)
        
        do
        {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: referencedController.audioSettings)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            
            if !audioRecorder.record()
            {
                print("HumanToPet: ERROR - Recording failed to start...")
                return
            }
            
            playButton.enabled = false
            print("HumanToPet: Recording started...")
            recordButton.setTitle("Press to Stop", forState: .Normal)
            
        }
        catch
        {
            print("HumanToPet: ERROR - Failure trying to make Audio Recorder!")
            cleanUpRecording(success: false)
        }
        
    }
    
    /* Play pressed- disable buttons and playback translation.  */
    @IBAction func playPressed(sender: UIButton)
    {
        recordButton.enabled = false
        playButton.enabled = false
    }
    
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            print("HumanToPet: ERROR - Audio did not finish recording!")
            cleanUpRecording(success: false)
        }
        
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool)
    {

    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if pickerView.isEqual(genderPicker)
        {
            return Gender.count
        }
        else if pickerView.isEqual(animalPicker)
        {
            return Animal.count
        }
        
        return 0
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Chalkboard SE", size: 16)
            pickerLabel?.textColor = UIColor.whiteColor()
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        if pickerView.isEqual(genderPicker)
        {
            pickerLabel?.text = Gender(rawValue: row)?.description
            return pickerLabel!;
        }
        else
        {
            pickerLabel?.text = Animal(rawValue: row)?.description
            return pickerLabel!;
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if pickerView.isEqual(genderPicker)
        {
            curGender = Gender(rawValue: row)
            print("HumanToPet: Gender changed to \(curGender.description)")
        }
        else if pickerView.isEqual(animalPicker)
        {
            curAnimal = Animal(rawValue: row)
            print("HumanToPet: Animal changed to \(curAnimal.description)")
        }
   }
}

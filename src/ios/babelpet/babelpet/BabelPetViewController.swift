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
    AVAudioPlayerDelegate, UIPickerViewDelegate
{
    // MARK: Local Variables
    var translations = [PetTranslation]()
    var curTrans: PetTranslation!
    var audioPath: String!
    var audioURL: NSURL!
    var curLanguage: Language!
    var curPower = Float(0)
    let powerThreshold = Float(-20.0)
    var curRecordingLength = Double(0)
    var referencedController: MainMenuViewController!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    // MARK: Properties
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var playBackButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var translationHeadingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var languageLabel: UILabel!
    
    // MARK: NSCoding
    func saveTranslations()
    {
        if NSKeyedArchiver.archiveRootObject(translations,
                                        toFile: PetTranslation.ArchiveURL.path!)
        {
            print("Pet translations saved without issue!")
        }
        else
        {
            print("Something happened and translations could not be saved")
        }
    }
    
    func loadTranslations() -> [PetTranslation]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(PetTranslation.ArchiveURL.path!) as? [PetTranslation]
    }
    
    // MARK: Convenience Functions
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: Functions
    func cleanUpRecording(success success: Bool)
    {
        if curLanguage == Language.日本語
        {
            recordButton.setTitle("Tap to Record", forState: .Normal)
        }
        else if curLanguage == Language.English
        {
            recordButton.setTitle("Tap to Record", forState: .Normal)
        }
        
        if audioRecorder != nil
        {
            audioRecorder.stop()
        }
        
        audioRecorder = nil
        
        if curPower < powerThreshold
        {
            translationLabel.text = "Pet was too quiet. Could not detect animal voice!"
            shareButton.enabled = false
            return
        }
        
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOfURL: audioURL!)
            
            print("Duration is \(originalVoice.duration)")
            
            /* Making sure we have at least one second of sampling */
            if originalVoice.duration < 1.5
            {
                translationLabel.text = "Recording not long enough! Try again!"
                shareButton.enabled = false
                return
            }
            
            recordButton.enabled = false
            audioPlayer = originalVoice
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            print("Playback failed")
            playBackButton.enabled = true
        }
        
        
        if(success)
        {
            let myDate = NSDate()
            curTrans = PetTranslation(audioURL: audioURL, transLanguage: curLanguage,
                                        duration: Float((audioPlayer?.duration)!), dateRecorded: myDate)
            curTrans.assignRandomTranslation()
            translations.append(curTrans)
            saveTranslations()
            translationLabel.text = curTrans.translatedText
            shareButton.enabled = true
        }
        else
        {
            translationLabel.text = "ERROR! RECORDING FAILED!"
            playBackButton.enabled = true
        }
    }
   
    
    // MARK: Actions
    @IBAction func recordStarted(sender: UIButton)
    {
        /* If we are in the middle of the recording, clean it up */
        if audioRecorder != nil
        {
            /* Updating the meter and discarding any recording which is too 
                quiet */
            audioRecorder.updateMeters()
            curPower = audioRecorder.peakPowerForChannel(0)
            print("Peak power is \(curPower)")
            
            cleanUpRecording(success: true)
            print("Recording finished without issue")
            return
        }
        
        /* Otherwise we are a new recording */
        audioPath = getDocumentsDirectory().stringByAppendingString("/petBabel\(translations.count).m4a")
        audioURL = NSURL(fileURLWithPath: audioPath)
        
        if curLanguage == Language.日本語
        {
            recordButton.setTitle("Tap to Stop", forState: .Normal)
        }
        else if curLanguage == Language.English
        {
            recordButton.setTitle("Tap to Stop", forState: .Normal)
        }
        
        do
        {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: referencedController.audioSettings)
            audioRecorder.delegate = self
            audioRecorder.meteringEnabled = true
            
            if !audioRecorder.record()
            {
                print("Recording failed to start...")
                return
            }
            
            playBackButton.enabled = false
            print("Recording started...")
            
        }
        catch
        {
            print("Failure trying to make Audio Recorder!")
            cleanUpRecording(success: false)
        }
    }
    
    @IBAction func backtoMainAction(sender: UIBarButtonItem)
    {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func startPlaybackAction(sender: UIButton)
    {
        print("Playback started....")
        playBackButton.enabled = false
        recordButton.enabled = false
        
        if curTrans == nil
        {
            print("Tried to play a nil recording")
            return
        }
        
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
            playBackButton.enabled = true
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.audioPlayer = referencedController.audioPlayer
        
        if let savedTranslations = loadTranslations()
        {
            translations += savedTranslations
        }
        
        /* Setting up Delegates  and default values */
        languagePicker.delegate = self
        curLanguage = Language.English
       
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        playBackButton.enabled = true
        recordButton.enabled = true
        
        if flag
        {
            print("Playback finished!")
        }
        else
        {
            print("Error with playback")
        }
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Language.count
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
        
        pickerLabel?.text = Language(rawValue: row)?.description
        
        return pickerLabel!;
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        curLanguage = Language(rawValue: row)
        print("Language changed to \(curLanguage.description)")
        
        /* If the user picked Japanese... */
        if curLanguage == Language.日本語
        {
            languageLabel.text = "言語"
            playBackButton.setTitle("再生", forState: .Normal)
            shareButton.setTitle("シェア", forState: .Normal)
            historyButton.setTitle("履歴", forState: .Normal)
            translationHeadingLabel.text = "翻訳"
        }
        /* English */
        else if curLanguage == Language.English
        {
            languageLabel.text = "Language"
            playBackButton.setTitle("Play", forState: .Normal)
            shareButton.setTitle("Share", forState: .Normal)
            historyButton.setTitle("History", forState: .Normal)
            translationHeadingLabel.text = "Translation"
        }
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "gotoTable"
        {
            let translationViewTable:TranslationHistoryTableViewController = segue.destinationViewController as! TranslationHistoryTableViewController
            translationViewTable.referencedController = self
        }
        else if(segue.identifier == "shareImage")
        {
            let imageViewController:ImageShareViewController = segue.destinationViewController as! ImageShareViewController
            imageViewController.referencedController = self
        }
    }
}


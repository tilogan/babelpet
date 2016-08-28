//
//  HumanToPetViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/23/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation
import FBAudienceNetwork

/* Various Pitches for premium content */
private var maleDogPitches: [Float] = [-1700, 1000, 1700]
private var femaleDogPitches: [Float] = [1000, 2000, 2400]
private var tubaPitches: [Float] = [-2400, -1700, -1000]
private var chipmunkPitches: [Float] = [2000, 2300, 2400]
private var freakPitches: [Float] = [-2400, 0, 2400]

enum SpeakingStyle: Int, CustomStringConvertible
{
    case Female = 0
    case Male = 1
    case Tuba = 2
    case Chipmunk = 3
    case Freak = 4
    
    static var count: Int { return SpeakingStyle.Freak.hashValue + 1}
    
    var description: String
    {
        switch self
        {
        case .Male: return "Male"
        case .Female   : return "Female"
        case .Tuba: return "Tuba"
        case .Chipmunk   : return "Chipmunk"
        case .Freak: return "Freak (Really Annoying)"
        }
    }
}

class HumanToPetViewController: UIViewController, AVAudioRecorderDelegate,
    AVAudioPlayerDelegate, UIPickerViewDelegate, SKPaymentTransactionObserver
{

    // MARK: Properties
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: Variables for premium purchase
    var transactionInProgress = false
    
    // MARK: Local Variables
    var audioURL: NSURL!
    var curOriginalURL: NSURL!
    var referencedController: MainMenuViewController!
    var audioRecorder: AVAudioRecorder!
    var curPower = Float(0)
    var curRecordingLength = Double(0)
    var curStyle: SpeakingStyle! = .Female
    var bufferList = [AVAudioPCMBuffer]()
    var completionInt = 0
    var audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    var curTransition = 0
    var translatedFile: AVAudioFile!
    var translatedURL: NSURL!
    var timer = NSTimer()
    var audioPlayer: AVAudioPlayer!
    var curStylePitch: [Float]!
    let powerThreshold = Float(-20.0)
    let pitch = AVAudioUnitTimePitch()
    let numOfTransitions = 3
    let timeoutDuration = 10.0
    
    // MARK: IAPurchaseViewController
    func paymentQueue(queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.Purchased:
                print("HumanToPet: Transaction completed successfully.")
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                self.didPurchasePremiumSuccessfully()
                transactionInProgress = false
            case SKPaymentTransactionState.Failed:
                print("HumanToPet: ERROR - Transaction Failed");
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                transactionInProgress = false
                self.didPurchasePremiumFail()
                curStyle = SpeakingStyle.Female
            default:
                print("HumanToPet: Status Code \(transaction.transactionState.rawValue)")
            }
        }
    }
    
    func didPurchasePremiumSuccessfully()
    {
        MainMenuViewController.isPremiumPurchased = true
        let defaultSettings = NSUserDefaults.standardUserDefaults()
        defaultSettings.setBool(true,
                                forKey: MainMenuViewController.premiumIdentifier)
        
        let alertController = UIAlertController(title: "Babel Pet Premium",
                                                message: MainMenuViewController.premiumPurchased,
                                                preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler:
            { (action: UIAlertAction!) in
                print("PetToHuman: Premium purchased dialog displayed.")
        }))
        
        self.presentViewController(alertController,
                                   animated: true,
                                   completion: nil)
        
    }
    
    func didPurchasePremiumFail()
    {
        
        let alertController = UIAlertController(title: "Unlock Babel Pet Premium",
                                                message: "Failed to complete transaction!",
                                                preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Ok",
            style: .Default,
            handler:
            { (action: UIAlertAction!) in
                print("HumanToPet: Premium purchased dialog displayed.")
        }))
        
        self.presentViewController(alertController,
                                   animated: true,
                                   completion: nil)
        
        genderPicker.selectRow(0, inComponent: 0, animated: true)
        
    }
    
    // MARK: Functions
    func upgradeHandler(alert: UIAlertAction!)
    {
        /* Purchase premium here */
        print("PetToHuman: Premium upgrade initiated")
        
        if self.transactionInProgress == true
        {
            print("MainMenu: Transaction already in progress!")
            return
        }
        
        if referencedController.productsArray.count == 0
        {
            print("MainMenu: Cannot retrieve products!")
            return
        }
        
        let payment = SKPayment(product: referencedController.productsArray[0])
        SKPaymentQueue.defaultQueue().addPayment(payment)
        self.transactionInProgress = true
    }
    
    /* Callback that is called if the recording goes above the maximum allowed
        time. */
    func recordingTimedOut()
    {
        print("HumanToPet: Recording timed out")
        recordPressed(recordButton)
    }
    
    /* Gets the document directory to save the transalted file in */
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    /* Mixes up the input recording into different pitches/tones */
    func audioBufferCallBack()
    {
        if !bufferList.isEmpty
        {
            pitch.pitch = curStylePitch[curTransition]
            
            curTransition = curTransition + 1
            
            if curTransition == numOfTransitions
            {
                curTransition = 0
            }
            
            let curIndex = Int(arc4random_uniform(UInt32(bufferList.count)))
            playerNode.scheduleBuffer(bufferList[curIndex], completionHandler: audioBufferCallBack)
            bufferList.removeAtIndex(curIndex)
            playerNode.play()
        }
        else
        {
            audioEngine.inputNode?.removeTapOnBus(0)
            completionInt = 1
        }
    }
    
    /* Takes the recorded sample and changes pitch/tone to make it funny and
        seemingly translated into pet speak */
    func translateIntoPet()
    {
        var audioFile: AVAudioFile!
        let numberOfSegments: UInt32 = 8
        bufferList = [AVAudioPCMBuffer]()
        
        /* Splitting our original recording into a bunch of different segments
            so that we can mix them up */
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
                bufferList.append(curBuffer)
            }
        }
        catch
        {
            print("HumanToPet: Translation failed!")
        }
        
        /* Creating an audio engine so that we can change pitch/speed */
        let format = bufferList[0].format
        audioEngine.connect(playerNode, to: pitch, format: format)
        audioEngine.connect(pitch, to: audioEngine.outputNode, format: format)
        
        let curIndex = Int(arc4random_uniform(UInt32(bufferList.count)))
        playerNode.scheduleBuffer(bufferList[curIndex], completionHandler: audioBufferCallBack)
        bufferList.removeAtIndex(curIndex)
        curTransition = 0
        
        /* Since we want all translations to be consistent, we should
         record the output of the audio engine */
        do
        {
            try translatedFile = AVAudioFile(forWriting: translatedURL,
                                    settings: audioEngine.inputNode!.inputFormatForBus(0).settings)
        }
        catch
        {
            print("HumanToPet: ERROR - Could not write file")
        }
        
        audioEngine.inputNode!.installTapOnBus(0, bufferSize: 1024,
                                              format: format)
        {
            (buffer, time) -> Void in
            
            do
            {
                try self.translatedFile.writeFromBuffer(buffer)
            }
            catch
            {
                print("HumanToPet: ERROR - Could not write file buffer")
            }
            
            return
        }
        
        /* Setting the speed */
        switch curStyle.rawValue
        {
            case SpeakingStyle.Male.rawValue:
                curStylePitch = maleDogPitches
            case SpeakingStyle.Female.rawValue:
                curStylePitch = femaleDogPitches
            case SpeakingStyle.Chipmunk.rawValue:
                curStylePitch = chipmunkPitches
            case SpeakingStyle.Tuba.rawValue:
                curStylePitch = tubaPitches
            case SpeakingStyle.Freak.rawValue:
                curStylePitch = freakPitches
            default:
                curStylePitch = maleDogPitches
        }
        
        pitch.pitch = curStylePitch[0]
        
        curTransition = curTransition + 1
    
        /* Starting the audio engine and waiting for the completion flag */
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
        
        /* Setting the buttons back */
        recordButton.setTitle("Press to Record", forState: .Normal)
        playButton.enabled = true
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
            
            statusLabel.text = "I hear ya! Here is the translation!"
            translateIntoPet()
            
        }
        catch
        {
            print("HumanToPet: ERROR - Could not initialize playback")
        }

        if !success
        {
            print("HumanToPet: ERROR - Failed recording!")
            playButton.enabled = false
        }

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        
        /* Adding the Facebook banner */
        if !MainMenuViewController.isPremiumPurchased
        {
        /* Adding the Facebook banner */
            let adView = FBAdView(placementID: "556114377906938_559339737584402",
                                  adSize: kFBAdSizeHeight50Banner,
                                  rootViewController: self)
            adView.frame = CGRectMake(0,
                                    self.view.frame.size.height-adView.frame.size.height,
                                    adView.frame.size.width,
                                    adView.frame.size.height)
            adView.loadAd()
            self.view.addSubview(adView)
        }
        
        recordButton.setTitle("Press to Record", forState: .Normal)
        genderPicker.delegate = self
        
        /* Setting up the audio engine */
        audioEngine.attachNode(playerNode)
        pitch.rate = 0.5
        pitch.overlap = 20
        audioEngine.attachNode(pitch)
        
        /* Configuring the file for translation */
        translatedURL = NSURL(string: getDocumentsDirectory().stringByAppendingString("/petTrans.caf"))
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func recordPressed(sender: UIButton)
    {
        timer.invalidate()
        
        /* If we are in the middle of the recording, clean it up */
        if audioRecorder != nil
        {
            /* Updating the meter and discarding any recording which is too
             quiet */
            audioRecorder.updateMeters()
            curPower = audioRecorder.peakPowerForChannel(0)
            print("HumanToPet: Peak power is \(curPower)")
            
            curOriginalURL = audioRecorder.url
            audioEngine.inputNode?.removeTapOnBus(0)
            
            cleanUpRecording(success: true)
            print("HumanToPet: Recording finished without issue")
            playButton.enabled = true
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
            timer = NSTimer.scheduledTimerWithTimeInterval(timeoutDuration,
                                                           target: self,
                                                           selector: #selector(HumanToPetViewController.recordingTimedOut),
                                                           userInfo: nil,
                                                           repeats: false)
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
        
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOfURL: self.translatedURL!)
            audioPlayer = originalVoice
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            print("HumanToPet: Playback failed")
            playButton.enabled = true
        }
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
        if flag
        {
            print("PetToHuman: Playback finished without issue.")
        }
        else
        {
            print("PetToHuman: ERROR - Issue with playback")
        }
        
        recordButton.enabled = true
        playButton.enabled = true

    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SpeakingStyle.count
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
        
        pickerLabel?.text = SpeakingStyle(rawValue: row)?.description
        return pickerLabel!;

    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        /* Checking to make sure premium is unlocked */
        if !MainMenuViewController.isPremiumPurchased && row != 0
        {
            let alertController = UIAlertController(title: "Unlock Premium Babel Pet",
                                                    message: MainMenuViewController.premiumMessage,
                                                    preferredStyle: .Alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Upgrade",
                                         style: UIAlertActionStyle.Default,
                                         handler: upgradeHandler)
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: UIAlertActionStyle.Cancel,
                                             handler: downgradeHandler)
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController,
                                       animated: true,
                                       completion: nil)
            
        }
        
        curStyle = SpeakingStyle(rawValue: row)
        print("HumanToPet: Gender changed to \(curStyle.description)")
        
        switch curStyle.rawValue
        {
        case SpeakingStyle.Male.rawValue:
            pitch.rate = 0.5
        case SpeakingStyle.Female.rawValue:
            pitch.rate = 0.6
        case SpeakingStyle.Chipmunk.rawValue:
            pitch.rate = 2
        case SpeakingStyle.Tuba.rawValue:
            pitch.rate = 0.125
        case SpeakingStyle.Freak.rawValue:
            pitch.rate = 0.06
        default:
            pitch.rate = 0.5
        }
    }
    
    func downgradeHandler(alert: UIAlertAction!)
    {
        curStyle = SpeakingStyle.Female
        genderPicker.selectRow(0, inComponent: 0, animated: true)
        pitch.rate = 3
        print("HumanToPet: Gender changed to \(curStyle.description)")
        print("HumanToPet: Premium upgrade declined")
    }
}

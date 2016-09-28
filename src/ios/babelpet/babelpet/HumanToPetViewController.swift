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
    case male = 0
    case female = 1
    case tuba = 2
    case chipmunk = 3
    case freak = 4
    
    static var count: Int { return SpeakingStyle.freak.hashValue + 1}
    
    var description: String
    {
        switch self
        {
        case .male: return "Male"
        case .female   : return "Female"
        case .tuba: return "Tuba"
        case .chipmunk   : return "Chipmunk"
        case .freak: return "Freak (Really Annoying)"
        }
    }
}

class HumanToPetViewController: UIViewController, AVAudioRecorderDelegate,
    AVAudioPlayerDelegate, UIPickerViewDelegate, SKPaymentTransactionObserver,
    FBAdViewDelegate
{

    // MARK: Properties
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    // MARK: Variables for premium purchase
    var transactionInProgress = false
    
    // MARK: Local Variables
    var audioURL: URL!
    var curOriginalURL: URL!
    var referencedController: MainMenuViewController!
    var audioRecorder: AVAudioRecorder!
    var curPower = Float(0)
    var curRecordingLength = Double(0)
    var curStyle: SpeakingStyle! = .male
    var bufferList = [AVAudioPCMBuffer]()
    var completionInt = 0
    var audioEngine = AVAudioEngine()
    var playerNode = AVAudioPlayerNode()
    var curTransition = 0
    var translatedFile: AVAudioFile!
    var translatedURL: URL!
    var timer = Timer()
    var audioPlayer: AVAudioPlayer!
    var curStylePitch: [Float]!
    let powerThreshold = Float(-20.0)
    let pitch = AVAudioUnitTimePitch()
    let numOfTransitions = 3
    let timeoutDuration = 10.0
    let barkSoundURL =  Bundle.main.url(forResource: "bark", withExtension: "aiff")!
    var buttonEffectPlayer = AVAudioPlayer()
    var adView: FBAdView!
    
    // MARK: IAPurchaseViewController
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.purchased:
                print("HumanToPet: Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.didPurchasePremiumSuccessfully()
                transactionInProgress = false
            case SKPaymentTransactionState.failed:
                print("HumanToPet: ERROR - Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                self.didPurchasePremiumFail()
                curStyle = SpeakingStyle.female
            default:
                print("HumanToPet: Status Code \(transaction.transactionState.rawValue)")
            }
        }
    }
    
    func didPurchasePremiumSuccessfully()
    {
        MainMenuViewController.isPremiumPurchased = true
        let defaultSettings = UserDefaults.standard
        defaultSettings.set(true,
                                forKey: MainMenuViewController.premiumIdentifier)
        
        let alertController = UIAlertController(title: "Babel Pet Premium",
                                                message: MainMenuViewController.premiumPurchased,
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok",
            style: .default,
            handler:
            { (action: UIAlertAction!) in
                print("PetToHuman: Premium purchased dialog displayed.")
        }))
        
        self.present(alertController,
                                   animated: true,
                                   completion: nil)
        
    }
    
    func didPurchasePremiumFail()
    {
        
        let alertController = UIAlertController(title: "Unlock Babel Pet Premium",
                                                message: "Failed to complete transaction!",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok",
            style: .default,
            handler:
            { (action: UIAlertAction!) in
                print("HumanToPet: Premium purchased dialog displayed.")
        }))
        
        self.present(alertController,
                                   animated: true,
                                   completion: nil)
        
        genderPicker.selectRow(0, inComponent: 0, animated: true)
        
    }
    
    // MARK: Functions
    func downgradeHandler(_ alert: UIAlertAction!)
    {
        curStyle = SpeakingStyle.female
        genderPicker.selectRow(0, inComponent: 0, animated: true)
        pitch.rate = 3
        print("HumanToPet: Gender changed to \(curStyle.description)")
        print("HumanToPet: Premium upgrade declined")
    }
    
    func upgradeHandler(_ alert: UIAlertAction!)
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
        
        let payment = SKPayment(product: referencedController.productsArray[0]!)
        SKPaymentQueue.default().add(payment)
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
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
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
            bufferList.remove(at: curIndex)
            playerNode.play()
        }
        else
        {
            pitch.removeTap(onBus: 0)
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
                let curBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                                frameCapacity: framesPerSegment)
                try audioFile.read(into: curBuffer)
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
        bufferList.remove(at: curIndex)
        curTransition = 0
        
        /* Since we want all translations to be consistent, we should
         record the output of the audio engine */
        do
        {
            try translatedFile = AVAudioFile(forWriting: translatedURL,
                                    settings: audioEngine.inputNode!.inputFormat(forBus: 0).settings)
        }
        catch
        {
            print("HumanToPet: ERROR - Could not write file")
        }
        
        pitch.installTap(onBus: 0, bufferSize: 1024,
                                              format: format)
        {
            (buffer, time) -> Void in
            
            do
            {
                try self.translatedFile.write(from: buffer)
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
            case SpeakingStyle.male.rawValue:
                curStylePitch = maleDogPitches
            case SpeakingStyle.female.rawValue:
                curStylePitch = femaleDogPitches
            case SpeakingStyle.chipmunk.rawValue:
                curStylePitch = chipmunkPitches
            case SpeakingStyle.tuba.rawValue:
                curStylePitch = tubaPitches
            case SpeakingStyle.freak.rawValue:
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
        recordButton.setTitle("Press to Record", for: UIControlState())
        playButton.isEnabled = true
    }
    
    /* Cleans up the recording */
    func cleanUpRecording(success: Bool)
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
            playButton.isEnabled = false
            recordButton.setTitle("Press to Record", for: UIControlState())
            return
        }
        
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOf: audioURL)
            print("HumanToPet: Duration is \(originalVoice.duration)")
            
            if originalVoice.duration < 1.5
            {
                print("HumanToPet: ERROR - duration not long enough!")
                statusLabel.text = "What was that?! Speak longer!"
                playButton.isEnabled = false
                recordButton.setTitle("Press to Record", for: UIControlState())
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
            playButton.isEnabled = false
        }

    }
    
    override func viewWillDisappear(_ animated:Bool)
    {
        SKPaymentQueue.default().remove(self)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        self.title = "Human to Pet"
        
        recordButton.setTitle("Press to Record", for: UIControlState())
        genderPicker.delegate = self
        
        /* Setting up the audio engine */
        audioEngine.attach(playerNode)
        pitch.rate = 0.5
        pitch.overlap = 20
        audioEngine.attach(pitch)
        
        /* Configuring the file for translation */
        translatedURL = URL(string: getDocumentsDirectory() + "/petTrans.caf")
        
        /* Config the buttons to auto-size */
        recordButton.titleLabel?.adjustsFontSizeToFitWidth = true
        statusLabel.adjustsFontSizeToFitWidth = true
        
        /* Adding the Facebook banner */
        if !MainMenuViewController.isPremiumPurchased
        {
            /* Adding the Facebook banner */
            adView = FBAdView(placementID: "556114377906938_559339737584402",
                              adSize: kFBAdSizeHeight50Banner,
                              rootViewController: self)
            adView.frame = CGRect(x: 0, y: self.view.frame.size.height-adView.frame.size.height,
                                  width: adView.frame.size.width, height: adView.frame.size.height)
            adView.delegate = self
            adView.isHidden = true
            self.view.addSubview(adView)
            adView.loadAd()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: FBAdViewDelegate
    func adView(_ adView: FBAdView, didFailWithError error: Error)
    {
        bottomMargin.constant = 10.0
        adView.isHidden = true
    }
    
    func adViewDidLoad(_ adView: FBAdView)
    {
        adView.isHidden = false
        bottomMargin.constant = 65.0
    }
    
    //MARK: Actions
    @IBAction func recordPressed(_ sender: UIButton)
    {
        timer.invalidate()
        
        do
        {
            buttonEffectPlayer = try AVAudioPlayer(contentsOf: barkSoundURL)
            buttonEffectPlayer.prepareToPlay()
            buttonEffectPlayer.play()
        }
        catch
        {
            print("MainMenu: ERROR - Could not play effect")
        }
        
        /* If we are in the middle of the recording, clean it up */
        if audioRecorder != nil
        {
            /* Updating the meter and discarding any recording which is too
             quiet */
            audioRecorder.updateMeters()
            curPower = audioRecorder.peakPower(forChannel: 0)
            print("HumanToPet: Peak power is \(curPower)")
            
            curOriginalURL = audioRecorder.url
            audioEngine.inputNode?.removeTap(onBus: 0)
            
            cleanUpRecording(success: true)
            print("HumanToPet: Recording finished without issue")
            playButton.isEnabled = true
            return
        }
        
        /* Otherwise we are a new recording */
        let audioPath = getDocumentsDirectory() + "/petBabelHuman.m4a"
        audioURL = URL(fileURLWithPath: audioPath)
        
        do
        {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: referencedController.audioSettings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            
            if !audioRecorder.record()
            {
                print("HumanToPet: ERROR - Recording failed to start...")
                return
            }
            
            playButton.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: timeoutDuration,
                                                           target: self,
                                                           selector: #selector(HumanToPetViewController.recordingTimedOut),
                                                           userInfo: nil,
                                                           repeats: false)
            print("HumanToPet: Recording started...")
            recordButton.setTitle("Press to Stop", for: UIControlState())
            
        }
        catch
        {
            print("HumanToPet: ERROR - Failure trying to make Audio Recorder!")
            cleanUpRecording(success: false)
        }
        
    }
    
    /* Play pressed- disable buttons and playback translation.  */
    @IBAction func playPressed(_ sender: UIButton)
    {
        recordButton.isEnabled = false
        playButton.isEnabled = false
        
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOf: self.translatedURL!)
            audioPlayer = originalVoice
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            print("HumanToPet: Playback failed")
            playButton.isEnabled = true
        }
    }
    
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool)
    {
        if !flag
        {
            print("HumanToPet: ERROR - Audio did not finish recording!")
            cleanUpRecording(success: false)
        }
        
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool)
    {
        if flag
        {
            print("PetToHuman: Playback finished without issue.")
        }
        else
        {
            print("PetToHuman: ERROR - Issue with playback")
        }
        
        recordButton.isEnabled = true
        playButton.isEnabled = true

    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SpeakingStyle.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Chalkboard SE", size: 16)
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = SpeakingStyle(rawValue: row)?.description
        return pickerLabel!;

    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        /* Checking to make sure premium is unlocked */
        if !MainMenuViewController.isPremiumPurchased && row != 0
        {
            let alertController = UIAlertController(title: "Unlock Premium Babel Pet",
                                                    message: MainMenuViewController.premiumMessage,
                                                    preferredStyle: .alert)
            
            // Create the actions
            let okAction = UIAlertAction(title: "Upgrade",
                                         style: UIAlertActionStyle.default,
                                         handler: upgradeHandler)
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: UIAlertActionStyle.cancel,
                                             handler: downgradeHandler)
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController,
                                       animated: true,
                                       completion: nil)
            
        }
        
        curStyle = SpeakingStyle(rawValue: row)
        print("HumanToPet: Gender changed to \(curStyle.description)")
        
        switch curStyle.rawValue
        {
        case SpeakingStyle.male.rawValue:
            pitch.rate = 0.5
        case SpeakingStyle.female.rawValue:
            pitch.rate = 0.6
        case SpeakingStyle.chipmunk.rawValue:
            pitch.rate = 2
        case SpeakingStyle.tuba.rawValue:
            pitch.rate = 0.125
        case SpeakingStyle.freak.rawValue:
            pitch.rate = 0.06
        default:
            pitch.rate = 0.5
        }
    }
}

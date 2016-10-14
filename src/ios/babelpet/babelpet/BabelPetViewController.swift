//
//  ViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/10/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import StoreKit

private let recordButtonTranslationStopped =
[
    Language.english: "Record",
    Language.japanese: "録音開始",
    Language.chinese: "記錄",
    Language.spanish: "Graba",
    Language.korean: "녹음"
]

private let recordButtonTranslationRecord =
[
    Language.english: "Stop",
    Language.japanese: "停止",
    Language.chinese: "停止",
    Language.spanish: "Detener",
    Language.korean: "그만 찍어요!"
]

private let tooQuietTranslation =
[
    Language.english: "I can't hear you! Speak up!",
    Language.japanese: "聞こえないよ〜！もっと大きな声で！！",
    Language.chinese: "我沒聽見！講久一點！",
    Language.spanish: "¡Habla mas alto!",
    Language.korean: "안들려요 더 크게 말해주세요"
]

private let tooShortTranslation =
[
    Language.english: "Huh!? Speak longer!",
    Language.japanese: "もっと話して！！",
    Language.chinese: "你說什麼?!講大聲點！",
    Language.spanish: "¡Hable más!",
    Language.korean: "뭐라구요? 더 길게 말해 주세요!"
]

private let playButtonTranslation =
[
    Language.english: "Play",
    Language.japanese: "再生",
    Language.chinese: "語言",
    Language.spanish: "Reproduce",
    Language.korean: "듣기"
]

private let shareButtonTranslation =
[
    Language.english: "Share",
    Language.japanese: "シェア",
    Language.korean: "공유",
    Language.chinese: "共享",
    Language.spanish: "Comparte"
]

private let historyButtonTranslation =
[
    Language.english: "History",
    Language.japanese: "履歴",
    Language.korean: "기록",
    Language.chinese: "歷史",
    Language.spanish: "Historia"
]

private let languageLabelTranslation =
[
    Language.english: "Language",
    Language.japanese: "言語",
    Language.korean: "언어",
    Language.chinese: "語言",
    Language.spanish: "Lenguaje"
]

private let translationDefaultTranslation =
[
    Language.english: "Translation",
    Language.japanese: "翻訳",
    Language.korean: "번역",
    Language.chinese: "翻譯",
    Language.spanish: "Traducción"
]

private let defaultTranslationPhrase =
[
    Language.english: "Translation",
    Language.japanese: "翻訳",
    Language.korean: "번역",
    Language.chinese: "翻譯",
    Language.spanish: "Traducción"
]


class BabelPetViewController: UIViewController, AVAudioRecorderDelegate,
    AVAudioPlayerDelegate, UIPickerViewDelegate, SKPaymentTransactionObserver,
    GADBannerViewDelegate
{
    // MARK: Local Variables
    var translations = [PetTranslation]()
    var curTrans: PetTranslation!
    var audioPath: String!
    var audioURL: URL!
    var curLanguage: Language!
    var curPower = Float(0)
    var curRecordingLength = Double(0)
    var referencedController: MainMenuViewController!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var timer = Timer()
    var completionInterrupt = Int(0)
    let powerThreshold = Float(-20.0)
    let timeoutDuration = 10.0
    let barkSoundURL =  Bundle.main.url(forResource: "bark", withExtension: "aiff")!
    let squeakSoundURL =  Bundle.main.url(forResource: "squeak", withExtension: "aiff")!
    let meowSoundURL =  Bundle.main.url(forResource: "meow", withExtension: "aiff")!
    var buttonEffectPlayer = AVAudioPlayer()

    
    // MARK: Variables for premium purchase
    var transactionInProgress = false
    
    // MARK: Properties
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var playBackButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var translationHeadingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var bannerView: GADBannerView!
    
    // MARK: NSCoding
    func saveTranslations()
    {
        if NSKeyedArchiver.archiveRootObject(translations,
                                        toFile: PetTranslation.ArchiveURL.path)
        {
            print("PetToHuman: Pet translations saved without issue!")
        }
        else
        {
            print("PetToHuman: ERROR - Something happened and translations could not be saved")
        }
    }
    
    func loadTranslations() -> [PetTranslation]?
    {
        return NSKeyedUnarchiver.unarchiveObject(withFile: PetTranslation.ArchiveURL.path) as? [PetTranslation]
    }
    
    // MARK: Convenience Functions
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // MARK: Functions
    func timeTimedOut()
    {
        print("Recording timed out")
        recordStarted(recordButton)
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
    
    
    func cleanUpRecording(success: Bool)
    {
        recordButton.setTitle(recordButtonTranslationStopped[curLanguage],
                              for: UIControlState())
        
        audioRecorder = nil
        
        if(success)
        {
            if curPower < powerThreshold
            {
                translationLabel.text = tooQuietTranslation[curLanguage]
                shareButton.isEnabled = false
                return
            }
            
            do
            {
                let originalVoice = try AVAudioPlayer(contentsOf: audioURL!)
                
                print("Duration is \(originalVoice.duration)")
                
                /* Making sure we have at least one second of sampling */
                if originalVoice.duration < 0.5
                {
                    translationLabel.text = tooShortTranslation[curLanguage]
                    shareButton.isEnabled = false
                    return
                }
                
                recordButton.isEnabled = false
                audioPlayer = originalVoice
                audioPlayer.delegate = self
                audioPlayer.play()
            }
            catch
            {
                print("PetToHuman: Playback failed")
            }
            
            let myDate = Date()
            curTrans = PetTranslation(audioURL: audioURL, transLanguage: curLanguage,
                                        duration: Float((audioPlayer?.duration)!), dateRecorded: myDate)
            curTrans.assignRandomTranslation()
            translations.append(curTrans)
            saveTranslations()
            translationLabel.text = curTrans.translatedText
            shareButton.isEnabled = true
        }
        else
        {
            translationLabel.text = "ERROR! RECORDING FAILED!"
            playBackButton.isEnabled = true
        }
    }
   
    
    // MARK: Actions
    @IBAction func recordStarted(_ sender: UIButton)
    {
        if audioRecorder != nil
        {
            /* Updating the meter and discarding any recording which is too quiet */
            timer.invalidate()
            
            audioRecorder.updateMeters()
            curPower = audioRecorder.peakPower(forChannel: 0)
            audioRecorder.stop()
            print("PetToHuman: Peak power is \(curPower)")
            
            cleanUpRecording(success: true)
            print("PetToHuman: Recording finished without issue")
            return
        }
        else
        {
            /* Otherwise we are a new recording */
            audioPath = getDocumentsDirectory() + "/petBabel\(translations.count).m4a"
            audioURL = URL(fileURLWithPath: audioPath)
            
            recordButton.setTitle(recordButtonTranslationRecord[curLanguage],
                                  for: UIControlState())
            
            do
            {
                audioRecorder = try AVAudioRecorder(url: audioURL,
                                                    settings: referencedController.audioSettings)
                audioRecorder.delegate = self
                audioRecorder.isMeteringEnabled = true
                
                if !audioRecorder.record()
                {
                    print("PetToHuman: ERROR - Recording failed to start...")
                    return
                }
                
                playBackButton.isEnabled = false
                print("PetToHuman: Recording started...")
                timer = Timer.scheduledTimer(timeInterval: timeoutDuration,
                                                               target: self,
                                                               selector: #selector(BabelPetViewController.timeTimedOut),
                                                               userInfo: nil,
                                                               repeats: false)
                
            }
            catch
            {
                print("PetToHuman: ERROR - Failure trying to make Audio Recorder!")
                cleanUpRecording(success: false)
            }

        }
    }
    
    @IBAction func backtoMainAction(_ sender: UIBarButtonItem)
    {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func startPlaybackAction(_ sender: UIButton)
    {
        print("PetToHuman: Playback started....")
        playBackButton.isEnabled = false
        recordButton.isEnabled = false
        
        if curTrans == nil
        {
            print("PetToHuman: ERROR - Tried to play a nil recording")
            return
        }
        
        do
        {
            let originalVoice = try AVAudioPlayer(contentsOf: curTrans.audioURL! as URL)
            audioPlayer = originalVoice
            audioPlayer.delegate = self
            audioPlayer.play()
        }
        catch
        {
            print("PetToHuman: ERROR - Playback failed")
            recordButton.isEnabled = true
            playBackButton.isEnabled = false
            shareButton.isEnabled = false
        }
    }
    
    // MARK: IAPurchaseViewController
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction])
    {
        for transaction in transactions
        {
            
            switch transaction.transactionState
            {
            case SKPaymentTransactionState.restored:
                print("PetToHuman: Transaction restored. ")
                self.didPurchasePremiumSuccessfully()
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
            case SKPaymentTransactionState.purchased:
                print("PetToHuman: Transaction completed successfully.")
                self.didPurchasePremiumSuccessfully()
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
            case SKPaymentTransactionState.failed:
                print("PetToHuman: ERROR - Transaction Failed");
                transactionInProgress = false
                SKPaymentQueue.default().finishTransaction(transaction)
                curLanguage = Language.english
                self.didPurchasePremiumFail()
            default:
                print("PetToHuman: Status Code \(transaction.transactionState.rawValue)")
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
        
        premiumCallBack()
        
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
                print("PetToHuman: Premium purchased dialog displayed.")
        }))
        
        self.present(alertController,
                                   animated: true,
                                   completion: nil)
        
        languagePicker.selectRow(0, inComponent: 0, animated: true)
        
        premiumCallBack()
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SKPaymentQueue.default().add(self)
        
        /* Adding the Google banner */
        if !MainMenuViewController.isPremiumPurchased
        {
            bannerView.adUnitID = "ca-app-pub-8253941476253631/5357369905"
            bannerView.adSize = kGADAdSizeSmartBannerPortrait
            bannerView.rootViewController = self
            bannerView.delegate = self
            bannerView.frame.size.width = self.view.frame.size.width
            bannerView.load(GADRequest())
        }
        else
        {
            bannerView.isHidden = true
        }
        
        
        
        if let savedTranslations = loadTranslations()
        {
            translations += savedTranslations
        }
        
        /* Setting up Delegates  and default values */
        languagePicker.delegate = self
        curLanguage = Language.english
        
        recordButton.titleLabel?.adjustsFontSizeToFitWidth = true
        shareButton.titleLabel?.adjustsFontSizeToFitWidth = true
        historyButton.titleLabel?.adjustsFontSizeToFitWidth = true
        playBackButton.titleLabel?.adjustsFontSizeToFitWidth = true
       
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: AVAudioRecorderDelegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder,
                                         successfully flag: Bool)
    {
        if !flag
        {
            print("PetToHuman: ERROR - Audio did not finish recording!")
            cleanUpRecording(success: false)
        }
        else
        {
            print("PetToHuman: Recording callback without issue")
        }
       
    }
    
    // MARK: AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer,
                                     successfully flag: Bool)
    {
        playBackButton.isEnabled = true
        recordButton.isEnabled = true
        
        if flag
        {
            print("PetToHuman: Playback finished!")
        }
        else
        {
            print("PetToHuman: ERROR: Error with playback")
        }
    }
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(_ pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return Language.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int,
                    forComponent component: Int, reusing view: UIView?) -> UIView
    {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Chalkboard SE", size: 16)
            pickerLabel?.textColor = UIColor.white
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = Language(rawValue: row)?.description
        
        return pickerLabel!;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int)
    {
        curLanguage = Language(rawValue: row)
        
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
        else
        {
            premiumCallBack()
        }
        
    }
    
    func premiumCallBack()
    {
        print("PetToHuman: Language changed to \(curLanguage.description)")
        
        languageLabel.text = languageLabelTranslation[curLanguage]
        playBackButton.setTitle(playButtonTranslation[curLanguage],
                                for: UIControlState())
        shareButton.setTitle(shareButtonTranslation[curLanguage],
                             for: UIControlState())
        historyButton.setTitle(historyButtonTranslation[curLanguage],
                               for: UIControlState())
        translationHeadingLabel.text =
            translationDefaultTranslation[curLanguage]
        translationLabel.text = defaultTranslationPhrase[curLanguage]
        recordButton.setTitle(recordButtonTranslationStopped[curLanguage],
                              for: UIControlState())
        curTrans = nil
        playBackButton.isEnabled = false
        shareButton.isEnabled = false
    }
    
    func downgradeHandler(_ alert: UIAlertAction!)
    {
        curLanguage = Language.english
        languagePicker.selectRow(0, inComponent: 0, animated: true)
        print("Language changed to \(curLanguage.description)")
        
        languageLabel.text = languageLabelTranslation[curLanguage]
        playBackButton.setTitle(playButtonTranslation[curLanguage],
                                for: UIControlState())
        shareButton.setTitle(shareButtonTranslation[curLanguage],
                             for: UIControlState())
        historyButton.setTitle(historyButtonTranslation[curLanguage],
                               for: UIControlState())
        translationHeadingLabel.text =
            translationDefaultTranslation[curLanguage]
        recordButton.setTitle(recordButtonTranslationStopped[curLanguage],
                              for: UIControlState())

        print("PetToHuman: Premium upgrade declined")
    }
    
    //MARK: Navigation
    override func viewWillDisappear(_ animated:Bool)
    {
        SKPaymentQueue.default().remove(self)
        super.viewWillDisappear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "gotoTable"
        {
            let translationViewTable:TranslationHistoryTableViewController =
                segue.destination as! TranslationHistoryTableViewController
            translationViewTable.referencedController = self
            
            do
            {
                buttonEffectPlayer = try AVAudioPlayer(contentsOf: meowSoundURL)
                buttonEffectPlayer.prepareToPlay()
                buttonEffectPlayer.play()
            }
            catch
            {
                print("BabelPet: ERROR - Could not play effect")
            }
        }
        else if(segue.identifier == "shareImage")
        {
            do
            {
                buttonEffectPlayer = try AVAudioPlayer(contentsOf: squeakSoundURL)
                buttonEffectPlayer.prepareToPlay()
                buttonEffectPlayer.play()
            }
            catch
            {
                print("BabelPet: ERROR - Could not play effect")
            }
            
            let imageViewController:ImageShareViewController =
                segue.destination as! ImageShareViewController
            imageViewController.referencedController = self
        }
    }
    
    // MARK: GADAdDelegate
    func adView(_ bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!)
    {
        print("BabelPet: Error loading ad: \(error.localizedDescription)")
        bottomMargin.constant = 10
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!)
    {
        print("BabelPet: Ad Loaded")
        bottomMargin.constant = bannerView.adSize.size.height + 10
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
}


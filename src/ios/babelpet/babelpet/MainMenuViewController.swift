//
//  MainMenuViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/17/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import iAd
import FBAudienceNetwork

class MainMenuViewController: UIViewController
{
    // MARK: Actions
    @IBAction func shintakoPressed(sender: UITapGestureRecognizer)
    {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://www.shintako.com")!)
    }
    
    // MARK: Static Variables
    static var isPremiumPurchased: Bool = false
    static let premiumMessage = "Upgrade to premium to remove ads and unlock all languages! Be a pal, your furrry friend is worth $0.99!"
    
    // MARK: Properties
    @IBOutlet weak var stackView: UIStackView!
    
    // MARK: Audio Engine
    var recordingSession: AVAudioSession!
    let audioSettings =
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
    ]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if !MainMenuViewController.isPremiumPurchased
        {
            FBAdSettings.addTestDevice("ebadf1868ee0b4c2eb364f912a7603e85824310a")
            let adView = FBAdView(placementID: "556114377906938_559339737584402",
                                  adSize: kFBAdSizeHeight50Banner,
                                  rootViewController: self)
            adView.frame = CGRectMake(0, self.view.frame.size.height-adView.frame.size.height,
                                      adView.frame.size.width, adView.frame.size.height)
            adView.loadAd()
            self.view.addSubview(adView)
        }

    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        /* We need the user to grant permission to use the microphone */
        recordingSession = AVAudioSession.sharedInstance()
        
        do
        {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
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
        
        if segue.identifier == "petToHuman"
        {
            let petToHuman:BabelPetViewController = segue.destinationViewController as! BabelPetViewController
            petToHuman.referencedController = self
        }
        else if(segue.identifier == "humanToPet")
        {
            let humanToPet:HumanToPetViewController = segue.destinationViewController as! HumanToPetViewController
            humanToPet.referencedController = self
        }
    }
    
}

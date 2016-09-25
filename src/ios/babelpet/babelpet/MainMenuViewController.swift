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
import StoreKit

class MainMenuViewController: UIViewController, SKProductsRequestDelegate
{
    // MARK: Actions
    @IBAction func shintakoPressed(_ sender: UITapGestureRecognizer)
    {
        UIApplication.shared.openURL(URL(string: "http://www.shintako.com")!)
    }
    
    // MARK: Static Variables
    static var isPremiumPurchased: Bool = false
    static let premiumMessage = "Upgrade to premium to remove ads and unlock all languages! Be a pal, your furrry friend is worth the kibble!"
    static let premiumIdentifier = "ShintakoLLC.BabelBet.premium"
    static let premiumPurchased = "Upgrade to Babel Pet Premium successful! You may need to restart the application for changes to take full effect."
    static var bannerBuffer: CGFloat!
    
    // MARK: Variables for premium purchase
    var productIDs: Array<String> = []
    var productsArray: Array<SKProduct?> = []
    
    // MARK: Properties
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    // MARK: Audio Engine
    var recordingSession: AVAudioSession!
    let audioSettings =
    [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 48000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
    ] as [String : Any]
    let barkSoundURL =  Bundle.main.url(forResource: "bark", withExtension: "aiff")!
    let squeakSoundURL =  Bundle.main.url(forResource: "squeak", withExtension: "aiff")!
    var buttonEffectPlayer = AVAudioPlayer()
    
    // MARK: Functions:

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        productIDs.append("ShintakoLLC.BabelBet.premium")
        requestProductInfo()
        
        let defaultSettings = UserDefaults.standard
        MainMenuViewController.isPremiumPurchased =
                defaultSettings.bool(forKey: MainMenuViewController.premiumIdentifier)

        if(MainMenuViewController.isPremiumPurchased)
        {
            MainMenuViewController.bannerBuffer = 10.0
        }
        else
        {
            MainMenuViewController.bannerBuffer = 65.0
        }
        
        
        if !MainMenuViewController.isPremiumPurchased
        {
            let adView = FBAdView(placementID: "556114377906938_559339737584402",
                                  adSize: kFBAdSizeHeight50Banner,
                                  rootViewController: self)
            adView.frame = CGRect(x: 0, y: self.view.frame.size.height-adView.frame.size.height,
                                      width: adView.frame.size.width, height: adView.frame.size.height)
            adView.loadAd()
            self.view.addSubview(adView)
        }
        else
        {
            bottomMargin.constant = 10
        }

    }
    
    func requestProductInfo()
    {
        if SKPaymentQueue.canMakePayments()
        {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            productRequest.delegate = self
            productRequest.start()
        }
        else
        {
            print("MainMenu: ERROR - Cannot perform In App Purchases.")
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }
    
    // MARK: SKProductsRequestDelegate
    func productsRequest(_ request: SKProductsRequest,
                         didReceive response: SKProductsResponse)
    {
        if response.products.count > 0
        {
            for product in response.products
            {
                productsArray.append(product)
            }
            print("MainMenu: Found \(response.products.count) products")
            
        }
        else
        {
            print("MainMenu: ERROR - There are no products.")
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        /* We need the user to grant permission to use the microphone */
        recordingSession = AVAudioSession.sharedInstance()
        
        do
        {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { (allowed: Bool) -> Void in
                DispatchQueue.main.async
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
            let petToHuman:BabelPetViewController = segue.destination as! BabelPetViewController
            petToHuman.referencedController = self
            
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
        }
        else if(segue.identifier == "humanToPet")
        {
            let humanToPet:HumanToPetViewController = segue.destination as! HumanToPetViewController
            humanToPet.referencedController = self
            
            do
            {
                buttonEffectPlayer = try AVAudioPlayer(contentsOf: squeakSoundURL)
                buttonEffectPlayer.prepareToPlay()
                buttonEffectPlayer.play()
            }
            catch
            {
                print("MainMenu: ERROR - Could not play effect")
            }
        }
        
    }
    
}

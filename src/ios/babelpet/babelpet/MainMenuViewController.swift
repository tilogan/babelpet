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

class MainMenuViewController: UIViewController, SKProductsRequestDelegate,
    FBAdViewDelegate, SKPaymentTransactionObserver
{
    // MARK: Actions
    @IBAction func shintakoPressed(_ sender: UITapGestureRecognizer)
    {
        UIApplication.shared.openURL(URL(string: "http://www.shintako.com")!)
    }
    
    @IBAction func restorePurchaseAction(_ sender: UIButton)
    {
        if (SKPaymentQueue.canMakePayments())
        {
            activityIndicator.startAnimating()
            SKPaymentQueue.default().restoreCompletedTransactions()
        }
    }
    
    // MARK: Static Variables
    static var isPremiumPurchased: Bool = false
    static let premiumMessage = "Upgrade to premium to remove ads and unlock all languages! Be a pal, your furrry friend is worth the kibble! (if you paid previously this will restore it for free)"
    static let premiumIdentifier = "ShintakoLLC.BabelBet.premium"
    static let premiumPurchased = "Upgrade to Babel Pet Premium successful! You may need to restart the application for changes to take full effect."
    static var bannerBuffer: CGFloat!
    var adView: FBAdView!
    
    // MARK: Variables for premium purchase
    var productIDs: Array<String> = []
    var productsArray: Array<SKProduct?> = []
    
    // MARK: Properties
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    var transactionInProgress: Bool = false
    
    // MARK: Functions:
    func downgradeHandler(_ alert: UIAlertAction!)
    {
        print("MainMenu: Premium upgrade declined")
        activityIndicator.stopAnimating()
    }
    
    func upgradeHandler(_ alert: UIAlertAction!)
    {
        /* Purchase premium here */
        print("MainMenu: Premium upgrade initiated")
        
        if self.transactionInProgress == true
        {
            print("MainMenu: Transaction already in progress!")
            return
        }
        
        if productsArray.count == 0
        {
            print("MainMenu: Cannot retrieve products!")
            return
        }
        
        let payment = SKPayment(product: productsArray[0]!)
        SKPaymentQueue.default().add(payment)
        self.transactionInProgress = true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        productIDs.append("ShintakoLLC.BabelBet.premium")
        requestProductInfo()
        
        let defaultSettings = UserDefaults.standard
        MainMenuViewController.isPremiumPurchased =
                defaultSettings.bool(forKey: MainMenuViewController.premiumIdentifier)
        
     //   FBAdSettings.addTestDevice("ebadf1868ee0b4c2eb364f912a7603e85824310a")
        
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
        
        if(MainMenuViewController.isPremiumPurchased)
        {
            restoreButton.isHidden = true
        }
        
        SKPaymentQueue.default().add(self)
        
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
        SKPaymentQueue.default().remove(self)
        super.viewWillDisappear(animated)
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
                print("MainMenu: Premium purchased dialog displayed.")
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
                print("MainMenu: Premium purchased dialog displayed.")
        }))
        
        self.present(alertController,
                     animated: true,
                     completion: nil)
        
        activityIndicator.stopAnimating()
        
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
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction])
    {
        print("MainMenu: Received Payment Transaction Response from Apple");
        for transaction:AnyObject in transactions
        {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction
            {
                switch trans.transactionState
                {
                case .purchased, .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    print("MainMenu: Purchase Passed!")
                    self.didPurchasePremiumSuccessfully()
                    restoreButton.isHidden = true
                    activityIndicator.stopAnimating()
                    break
                case .failed:
                    print("MainMenu: Purchased Failed!")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.didPurchasePremiumFail()
                    break
                default:
                    print("MainMenu: default")
                    break
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error)
    {
        activityIndicator.stopAnimating()
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
    {
        activityIndicator.stopAnimating()
        if (SKPaymentQueue.default().transactions.count == 0)
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
    }
    
}

//
//  MainMenuViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/17/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import StoreKit
import AVFoundation
import GoogleMobileAds

class MainMenuViewController: UIViewController, SKProductsRequestDelegate,
    SKPaymentTransactionObserver, GADBannerViewDelegate
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
    
    // MARK: Variables for premium purchase
    var productIDs: Array<String> = []
    var productsArray: Array<SKProduct?> = []
    
    // MARK: Properties
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bannerView: GADBannerView!
    
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
        
        if(MainMenuViewController.isPremiumPurchased)
        {
            restoreButton.isHidden = true
        }
        
        SKPaymentQueue.default().add(self)
        restoreButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
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
                        print("MainMenu: Recording granted")
                    } else
                    {
                        print("MainMenu: Permisison for microphone denied")
                        let alert = UIAlertController(title: "Microphone Usage Denied",
                          message: "This application requires microphone usage. Please enable in Settings/Privacy/Microphone.",
                          preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok",
                                                      style: UIAlertActionStyle.default,
                                                      handler: nil))
                        self.present(alert, animated: true, completion: nil)
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
    
    // MARK: GADAdDelegate
    func adView(_ bannerView: GADBannerView!,
                didFailToReceiveAdWithError error: GADRequestError!)
    {
        print("MainMenu: Error loading ad: \(error.localizedDescription)")
        bannerView.isHidden = true
        bottomMargin.constant = 10
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView!)
    {
        print("MainMenu: Ad Loaded")
        bannerView.isHidden = false
        bottomMargin.constant = bannerView.adSize.size.height + 10
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    
}

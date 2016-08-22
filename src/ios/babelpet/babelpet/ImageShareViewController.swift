//
//  ImageShareViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/28/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import FBAudienceNetwork

private let shareDescriptionTranslation =
[
    Language.日本語: "録音開始",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Some Spanish"
]

private let libraryButtonTranslation =
[
    Language.日本語: "Some Japanese",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Some Spanish"
]

private let takePictureButtonTranslation =
[
    Language.日本語: "Some Japanese",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Some Spanish"
]

private let translationHeaderTranslation =
[
    Language.日本語: "Some Japanese",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Some Spanish"
]

private let playButtonTranslation =
[
    Language.日本語: "Some Japanese",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Some Spanish"
]

private let generateVideoTranslation =
[
    Language.日本語: "Some Japanese",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Some Spanish"
]

class ImageShareViewController: UIViewController,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate,
                        UITextFieldDelegate
{
    // MARK: Properties
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var textScroller: UIScrollView!
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var pictureButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var translationLabel: UILabel!
    
    // MARK: Variables
    var referencedController: BabelPetViewController!

    // MARK: Actions
    @IBAction func playTranslationOption(sender: UIButton)
    {
        referencedController.startPlaybackAction(sender)
    }
    
    @IBAction func takePictureAction(sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func chooseLibraryAction(sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        /* Adding the Facebook banner */
        if !MainMenuViewController.isPremiumPurchased
        {
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
        
        let curLanguage = referencedController.curLanguage
        
        if curLanguage != Language.English
        {
            translationTextField.text = referencedController.curTrans.translatedText
            translationTextField.delegate = self
            
            libraryButton.setTitle(libraryButtonTranslation[curLanguage],
                                   forState: .Normal)
            pictureButton.setTitle(takePictureButtonTranslation[curLanguage],
                                   forState: .Normal)
            generateButton.setTitle(generateVideoTranslation[curLanguage],
                                    forState: .Normal)
            playButton.setTitle(playButtonTranslation[curLanguage],
                                    forState: .Normal)
            translationLabel.text = translationHeaderTranslation[curLanguage]
            directionsLabel.text = shareDescriptionTranslation[curLanguage]
        }
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        petImage.image = selectedImage
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "showPreview"
        {
            let videoPreviewController:VideoPreviewViewController = segue.destinationViewController as! VideoPreviewViewController
            videoPreviewController.referencedController = self
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        translationTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        let curTrans = referencedController.curTrans
        
        if !textField.text!.isEmpty && curTrans.translatedText != textField.text
        {
            let indexOfTrans = referencedController.translations.indexOf(curTrans)
            curTrans.translatedText = textField.text
            
            if(indexOfTrans != nil)
            {
                referencedController.translations.removeAtIndex(indexOfTrans!)
                referencedController.translations.append(curTrans)
                referencedController.curTrans = curTrans
                referencedController.translationLabel.text = curTrans.translatedText
            }
        }
    }
    

}

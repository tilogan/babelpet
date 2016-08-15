//
//  ImageShareViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/28/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit

class ImageShareViewController: UIViewController,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate,
                        UITextFieldDelegate
{
    // MARK: Properties
    @IBOutlet weak var translationTextField: UITextField!
    @IBOutlet weak var textScroller: UIScrollView!
    @IBOutlet weak var petImage: UIImageView!
    
    // MARK: Variables
    var referencedController: BabelPetViewController!
    
    // MARK: Actions
    @IBAction func generateVideoAction(sender: UIButton)
    {
        
    }
    
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
        translationTextField.text = referencedController.curTrans.translatedText
        translationTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
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

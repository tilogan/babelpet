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
    Language.Japanese: "Babel Pet はあなたのペットの写真、音声、翻訳をご友人とSNSでシェアすることができます。写真を撮影/選択し翻訳したペットの音声＋言葉をFACEBOOKやInstagramに投稿して可愛いペットを紹介、自慢しちゃいましょう！！！",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "¡“Babel Pet” te permite tomar fotos de tu peludo amigo, pega una edición/audio y comparte con tus amigos!, ¡Simplemente escoge/toma una foto, cambia la edición si quieres y genera un video adorable!",
    Language.Korean: "Babel Pet으로 여러분의 반려 동물의 사진을 찍어 그들의 말을 번역하고, 친구들과 공유하세요!  갖고있는 반려동물의 사진을 선택하거나,  사진찍기를 선택하여 새로운 사진을 찍고 , 그들의  언어를 번역하여 사랑스러운 영상도 만들어 보세요!"
]

private let libraryButtonTranslation =
[
    Language.Japanese: "写真を選ぶ",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Escoge desde la librería",
    Language.Korean: "라이브러리에서 선택하기"
]

private let takePictureButtonTranslation =
[
    Language.Japanese: "撮影",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Toma una foto",
    Language.Korean: "사진 찍기"
]

private let translationHeaderTranslation =
[
    Language.Japanese: "翻訳",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Traducción",
    Language.Korean: "번역"
]

private let playButtonTranslation =
[
    Language.Japanese: "再生",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Reproduce",
    Language.Korean: "듣기"
]

private let generateVideoTranslation =
[
    Language.Japanese: "写真・音声付翻訳作成",
    Language.Chinese: "Some Chinese",
    Language.Spanish: "Generar traducción de video",
    Language.Korean: "비디오 번역 생성하기"
]

private let colorLabelTranslation =
[
    Language.Japanese: "色:",
    Language.Chinese: "顏色:",
    Language.Spanish: "Color:",
    Language.Korean: "색:"
]

private let colorChoices =
[
    UIColor.blackColor(),
    UIColor.blueColor(),
    UIColor.greenColor(),
    UIColor.orangeColor(),
    UIColor.purpleColor(),
    UIColor.redColor(),
    UIColor.whiteColor(),
    UIColor.yellowColor()
]

private let colorStringEnglish =
[
    "Black",
    "Blue",
    "Green",
    "Orange",
    "Purple",
    "Red",
    "White",
    "Yellow"
]

private let colorStringSpanish =
[
    "Negro",
    "Azul",
    "Verde",
    "Naranja",
    "Púrpura",
    "Rojo",
    "Blanco",
    "Amarillo"
]

private let colorStringKorean =
[
    "검은",
    "푸른",
    "녹색",
    "주황색",
    "보라색",
    "빨간",
    "화이트",
    "노랑"
]

private let colorStringChinese =
[
    "黑色",
    "藍色",
    "綠色",
    "橙子",
    "紫色",
    "紅",
    "白色",
    "黃色"
]

private let colorStringJapanese =
[
    "黒",
    "青",
    "緑",
    "橙",
    "紫",
    "赤",
    "白",
    "黄"
]

private let colorStringChoices =
[
    Language.Spanish: colorStringSpanish,
    Language.English: colorStringEnglish,
    Language.Japanese: colorStringJapanese,
    Language.Chinese: colorStringChinese,
    Language.Korean: colorStringKorean
]



class ImageShareViewController: UIViewController,
                        UIImagePickerControllerDelegate,
                        UINavigationControllerDelegate,
                        UITextFieldDelegate,
                        UIPickerViewDelegate
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
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    // MARK: Variables
    var referencedController: BabelPetViewController!
    var curColor: UIColor!

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
        
        /* Changing the default color to blue */
        curColor = UIColor.blueColor()
        colorPicker.selectRow(1, inComponent: 0, animated: false)
        
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
            colorLabel.text = colorLabelTranslation[curLanguage]
        }
        
        translationTextField.text = referencedController.curTrans.translatedText
        translationTextField.delegate = self
        
        directionsLabel.adjustsFontSizeToFitWidth = true
        libraryButton.titleLabel!.adjustsFontSizeToFitWidth = true
        pictureButton.titleLabel!.adjustsFontSizeToFitWidth = true
        translationLabel.adjustsFontSizeToFitWidth = true
        playButton.titleLabel!.adjustsFontSizeToFitWidth = true
        colorLabel.adjustsFontSizeToFitWidth = true
        colorPicker.delegate = self
        
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
    
    // MARK: UIPickerViewDelegate
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return colorChoices.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView
    {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont(name: "Futara", size: 16)
            pickerLabel?.textColor = UIColor.whiteColor()
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }
        
        pickerLabel?.text = colorStringChoices[referencedController.curLanguage]![row]
        return pickerLabel!;
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        curColor = colorChoices[row]
        print("ImageShare: Color changed to \(colorStringEnglish[row])")
    }

}

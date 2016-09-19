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
    Language.japanese: "Babel Pet はあなたのペットの写真、音声、翻訳をご友人とSNSでシェアすることができます。写真を撮影/選択し翻訳したペットの音声＋言葉をFACEBOOKやInstagramに投稿して可愛いペットを紹介、自慢しちゃいましょう！！！",
    Language.chinese: "巴別寵物讓你給你毛茸茸的朋友拍照片, 加上翻譯/音頻, 並與朋友分享！只需在下面選擇/拍攝一張照片,更改翻譯，並製作出可愛的視頻",
    Language.spanish: "¡“Babel Pet” te permite tomar fotos de tu peludo amigo, pega una edición/audio y comparte con tus amigos!, ¡Simplemente escoge/toma una foto, cambia la edición si quieres y genera un video adorable!",
    Language.korean: "Babel Pet으로 여러분의 반려 동물의 사진을 찍어 그들의 말을 번역하고, 친구들과 공유하세요!  갖고있는 반려동물의 사진을 선택하거나,  사진찍기를 선택하여 새로운 사진을 찍고 , 그들의  언어를 번역하여 사랑스러운 영상도 만들어 보세요!"
]

private let libraryButtonTranslation =
[
    Language.japanese: "写真を選ぶ",
    Language.chinese: "從圖書館選擇",
    Language.spanish: "Escoge desde la librería",
    Language.korean: "라이브러리에서 선택하기"
]

private let takePictureButtonTranslation =
[
    Language.japanese: "撮影",
    Language.chinese: "拍照",
    Language.spanish: "Toma una foto",
    Language.korean: "사진 찍기"
]

private let translationHeaderTranslation =
[
    Language.japanese: "翻訳:",
    Language.chinese: "翻譯:",
    Language.spanish: "Traducción:",
    Language.korean: "번역:"
]

private let playButtonTranslation =
[
    Language.japanese: "再生",
    Language.chinese: "播放",
    Language.spanish: "Reproduce",
    Language.korean: "듣기"
]

private let generateVideoTranslation =
[
    Language.japanese: "写真・音声付翻訳作成",
    Language.chinese: "製作視頻翻譯",
    Language.spanish: "Generar traducción de video",
    Language.korean: "비디오 번역 생성하기"
]

private let colorLabelTranslation =
[
    Language.japanese: "文字色:",
    Language.chinese: "顏色:",
    Language.spanish: "Color:",
    Language.korean: "색:"
]

private let colorChoices =
[
    UIColor.yellow,
    UIColor.black,
    UIColor.blue,
    UIColor.green,
    UIColor.orange,
    UIColor.purple,
    UIColor.red,
    UIColor.white,
]

private let colorStringEnglish =
[
    "Yellow",
    "Black",
    "Blue",
    "Green",
    "Orange",
    "Purple",
    "Red",
    "White",
]

private let colorStringSpanish =
[
    "Amarillo",
    "Negro",
    "Azul",
    "Verde",
    "Naranja",
    "Púrpura",
    "Rojo",
    "Blanco",
]

private let colorStringKorean =
[
    "노랑",
    "검은",
    "푸른",
    "녹색",
    "주황색",
    "보라색",
    "빨간",
    "화이트",
]

private let colorStringChinese =
[
    "黃色",
    "黑色",
    "藍色",
    "綠色",
    "橙子",
    "紫色",
    "紅",
    "白色",
]

private let colorStringJapanese =
[
    "きいろ",
    "くろ",
    "あお",
    "みどり",
    "オレンジ",
    "むらさき",
    "あか",
    "しろ",
]

private let colorStringChoices =
[
    Language.spanish: colorStringSpanish,
    Language.english: colorStringEnglish,
    Language.japanese: colorStringJapanese,
    Language.chinese: colorStringChinese,
    Language.korean: colorStringKorean
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
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    // MARK: Variables
    var referencedController: BabelPetViewController!
    var curColor: UIColor!

    // MARK: Actions
    @IBAction func playTranslationOption(_ sender: UIButton)
    {
        referencedController.startPlaybackAction(sender)
    }
    
    @IBAction func takePictureAction(_ sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func chooseLibraryAction(_ sender: UIButton)
    {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    func keyboardNotification(notification: NSNotification)
    {
        if let userInfo = notification.userInfo
        {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height
            {
                self.bottomMargin?.constant = MainMenuViewController.bannerBuffer
            }
            else
            {
                self.bottomMargin?.constant = endFrame?.size.height ?? MainMenuViewController.bannerBuffer
            }
            UIView.animate(withDuration: duration,
                            delay: TimeInterval(0),
                            options: animationCurve,
                            animations: { self.view.layoutIfNeeded() },
                            completion: nil)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        
        /* Changing the default color to blue */
        curColor = UIColor.yellow
        colorPicker.selectRow(1, inComponent: 0, animated: false)
        
        /* Adding the Facebook banner */
        if !MainMenuViewController.isPremiumPurchased
        {
            let adView = FBAdView(placementID: "556114377906938_559339737584402",
                                adSize: kFBAdSizeHeight50Banner,
                                rootViewController: self)
            adView.frame = CGRect(x: 0,
                                    y: self.view.frame.size.height-adView.frame.size.height,
                                    width: adView.frame.size.width,
                                    height: adView.frame.size.height)
            adView.loadAd()
            self.view.addSubview(adView)
        }
        else
        {
            bottomMargin.constant = 10
        }
        
        
        let curLanguage = referencedController.curLanguage
        
        if curLanguage != Language.english
        {
            libraryButton.setTitle(libraryButtonTranslation[curLanguage!],
                                   for: UIControlState())
            pictureButton.setTitle(takePictureButtonTranslation[curLanguage!],
                                   for: UIControlState())
            generateButton.setTitle(generateVideoTranslation[curLanguage!],
                                    for: UIControlState())
            playButton.setTitle(playButtonTranslation[curLanguage!],
                                    for: UIControlState())
            translationLabel.text = translationHeaderTranslation[curLanguage!]
            directionsLabel.text = shareDescriptionTranslation[curLanguage!]
            colorLabel.text = colorLabelTranslation[curLanguage!]
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
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any])
    {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        petImage.image = selectedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
         dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showPreview"
        {
            let videoPreviewController:VideoPreviewViewController = segue.destination as! VideoPreviewViewController
            videoPreviewController.referencedController = self
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        translationTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let curTrans = referencedController.curTrans
        
        if !textField.text!.isEmpty && curTrans?.translatedText != textField.text
        {
            let indexOfTrans = referencedController.translations.index(of: curTrans!)
            curTrans?.translatedText = textField.text
            
            if(indexOfTrans != nil)
            {
                referencedController.translations.remove(at: indexOfTrans!)
                referencedController.translations.append(curTrans!)
                referencedController.curTrans = curTrans
                referencedController.translationLabel.text = curTrans?.translatedText
            }
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
        return colorChoices.count
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
        
        pickerLabel?.text = colorStringChoices[referencedController.curLanguage]![row]
        return pickerLabel!;
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int,
                    inComponent component: Int)
    {
        curColor = colorChoices[row]
        print("ImageShare: Color changed to \(colorStringEnglish[row])")
    }

}

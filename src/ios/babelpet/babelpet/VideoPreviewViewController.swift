//
//  VideoPreviewViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/28/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos
import FBSDKLoginKit
import FBSDKShareKit
import FBAudienceNetwork

class VideoPreviewViewController: UIViewController, FBInterstitialAdDelegate
{
    // MARK: Variables
    var referencedController: ImageShareViewController!
    var savedVideo: URL!
    var assetURL: String!
    var myDialog: FBSDKShareDialog!
    var fullSiteAd: FBInterstitialAd!
    
    // MARK: Video generation
    var writer: AVAssetWriter!
    
    // MARK: Properties
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet var playGesture: UITapGestureRecognizer!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomMargin: NSLayoutConstraint!
    
    // MARK: Actions
    @IBAction func playVideoAction(_ sender: UITapGestureRecognizer)
    {
        let player = AVPlayer(url: self.savedVideo)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true)
        {
            playerViewController.player!.play()
        }
    }
    
    @IBAction func saveToPhonePressed(_ sender: UIButton)
    {
        if(self.assetURL.isEmpty)
        {
            saveVideoToLibrary()
        }
        
        let alertController = UIAlertController(title: "Video saved",
                                                message: "Video saved to phone library!!",
                                                preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Ok",
            style: .default,
            handler:
            { (action: UIAlertAction!) in
                print("ImageShare: Video saved to phone.")
        }))
        
        self.present(alertController,
                                   animated: true,
                                   completion: nil)
    }
    
    
    /* Instagram is easier than Facebook. Just save the asset, and then
     construct/escape the string into the Instagram application */
    @IBAction func shareInstagram(_ sender: AnyObject)
    {
        /* We need to save before we can share */
        if self.assetURL.isEmpty
        {
            saveVideoToLibrary()
        }
        
        /* Making sure we saved */
        if self.assetURL.isEmpty
        {
            print("PetShare: ERROR: Saving to instagram")
            return
        }
        
        /* Otherwise construct the URL and send it to the external application */
        let escapedPath = self.assetURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let instaString = String.localizedStringWithFormat("instagram://library?AssetPath=%@", escapedPath!)
        let instagramURL: URL = URL(string: instaString)!
        UIApplication.shared.openURL(instagramURL)
    }
    
    /* Share to Facebook. We need to get credentials from Facebook before
        calling the dialog to share the video */
    @IBAction func shareFacebookButton(_ sender: UIButton)
    {
        /* If the user is not already logged in to Facebook, login */
        if FBSDKAccessToken.current() == nil
        {
            /* Make the login manager and prompt the user for the login */
            let loginManager: FBSDKLoginManager = FBSDKLoginManager()
            loginManager.loginBehavior = FBSDKLoginBehavior.native
            loginManager.logIn (withReadPermissions: ["public_profile"],
                                                      from:  self,
                                                      handler:
                { (response:FBSDKLoginManagerLoginResult?, error: Error?) in
                if(error != nil)
                {
                    print("PetShare: ERROR - FACEBOOK: Login Error Happened")
                    return
                }
                else if(response?.isCancelled)!
                {
                    print("PetShare: ERROR - FACEBOOK: Login canceled")
                    return
                }
                else
                {
                    print("PetShare: FACEBOOK: Login worked")
                }
            })
        }
        
        /* The Facebook share dialog only accepts an asset link. To get this    
            we have to first save it to the user's local library and then
            convert the rsulting URL to an asset URL */
        if(self.assetURL.isEmpty)
        {
            saveVideoToLibrary()
        }
        
        if(self.assetURL.isEmpty)
        {
            print("PetShare: ERROR - Saving video to library!")
        }
        
        /* Now we need to share. Create the asset URL and open the dialog */
        let avURL = AVURLAsset(url: URL(string: self.assetURL)!)
        let fbShareVideo: FBSDKShareVideo = FBSDKShareVideo(videoURL: avURL.url)
        let fbShareContent: FBSDKShareVideoContent = FBSDKShareVideoContent()
        fbShareContent.video = fbShareVideo
    
        /* Displaying the dialog */
        myDialog = FBSDKShareDialog()
        myDialog.fromViewController = self
        myDialog.shareContent = fbShareContent
        myDialog.mode = FBSDKShareDialogMode.shareSheet
        myDialog.show()

    }
    
    // MARK: Functions
    
    /* Takes the meme and saves it to the video library. This is needed to 
        share on the various media platforms */
    func saveVideoToLibrary()
    {
        var videoAssetPlaceholder:PHObjectPlaceholder!
        var completionInt = 0
        
        /* This class takes a local video file on the file system and saves
           it to the asset library. From there we parse the asset URL and
           save it as a class object */
        PHPhotoLibrary.shared().performChanges(
            {
                let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.savedVideo)
                videoAssetPlaceholder = request!.placeholderForCreatedAsset
            })
        { saved, error in
            if saved
            {
                let localID = videoAssetPlaceholder.localIdentifier
                let assetID = localID.replacingOccurrences(of: "/.*", with: "",
                                                                           options: NSString.CompareOptions.regularExpression,
                                                                           range: nil)
                let ext = "mov"
                self.assetURL =
                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                print("PetShare: Video saved to library")
            }
            
            completionInt = 1
        }
        
        /* Poll for completion */
        while completionInt == 0
        {
            
        }
    }
    
    /* Takes the image and the text and makes an overlayed movie out of it */
    func convertImagetoPetMovie(_ petImage: UIImage, videoPath: String,
                                duration: Float, audioURL: URL) -> URL?
    {
        var writeSize = petImage.size
        var scaledImage = UIImage()

        /* We need to convert the picture to a usable width so it doesn't overload
         the social media site or the movie player. If the width is greater
         than 1000 pixels, set it down to 1000 pixels (and proportion the
         height) so that we can work with it */
        if writeSize.width > 1000
        {
            writeSize.height = (1000.0 * writeSize.height)/writeSize.width
            writeSize.width = 1000.0
            
            UIGraphicsBeginImageContext(CGSize(width: writeSize.width, height: writeSize.height))
            petImage.draw(in: CGRect(x: 0, y: 0, width: writeSize.width, height: writeSize.height))
            scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        else
        {
            scaledImage = petImage
        }
        
        /* Create AVAssetWriter to write video */
        guard let assetWriter = createAssetWriter(videoPath, size: scaledImage.size) else
        {
            print("PetShare: ERROR - Converting images to video: AVAssetWriter not created")
            return nil
        }
        
        /* Create AVAssetWriterInputPixelBufferAdaptor */
        let writerInput = assetWriter.inputs.filter{ $0.mediaType == AVMediaTypeVideo }.first!
        let sourceBufferAttributes : [String : AnyObject] =
            [
                kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB) as AnyObject,
                kCVPixelBufferWidthKey as String : scaledImage.size.width as AnyObject,
                kCVPixelBufferHeightKey as String : scaledImage.size.height as AnyObject,
            ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput,
                                                                      sourcePixelBufferAttributes: sourceBufferAttributes)
        
        /* Start writing session */
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: kCMTimeZero)
        if (pixelBufferAdaptor.pixelBufferPool == nil)
        {
            print("PetShare: ERROR - Converting images to video: pixelBufferPool nil after starting session")
            return nil
        }
        
        var frameDuration = kCMTimeZero
        var completionFlag = 0

        /* Writing a frame at the beginning to start the write */
        if !appendPixelBufferForImageAtURL(scaledImage, pixelBufferAdaptor: pixelBufferAdaptor,
                                           presentationTime: frameDuration)
        {
            print("PetShare: ERROR - Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
            return nil
        }
        
        /* Writing one frame at the end to make the length */
        frameDuration = CMTimeMake(Int64(ceil(duration)),1)
        if !appendPixelBufferForImageAtURL(scaledImage, pixelBufferAdaptor: pixelBufferAdaptor,
                                           presentationTime: frameDuration)
        {
            print("PetShare: ERROR - Converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
            return nil
        }
        
        writerInput.markAsFinished()
        assetWriter.finishWriting
            {
                print("PetShare: Recording finished!")
                completionFlag = 1
        }
        
        while completionFlag != 1
        {
            
        }
        
        /* Now merging the audio and video */
        let composition = AVMutableComposition()
        let trackVideo:AVMutableCompositionTrack =
            composition.addMutableTrack(withMediaType: AVMediaTypeVideo,
                                                     preferredTrackID: CMPersistentTrackID())
        let trackAudio:AVMutableCompositionTrack =
            composition.addMutableTrack(withMediaType: AVMediaTypeAudio,
                                                     preferredTrackID: CMPersistentTrackID())
        let videoURL = URL(fileURLWithPath: videoPath)
        let sourceVideo = AVURLAsset(url: videoURL, options: nil)
        let sourceAudio = AVURLAsset(url: audioURL, options: nil)
        
        let audioTracks = sourceAudio.tracks(withMediaType: AVMediaTypeAudio)
        let videoTracks = sourceVideo.tracks(withMediaType: AVMediaTypeVideo)
        
        if audioTracks.count == 0 || videoTracks.count == 0
        {
            print("PetShare: ERROR - Could not compose video")
            return nil
        }
        
        do
        {
            let curAudio = audioTracks[0] as AVAssetTrack
            let curVideo = videoTracks[0] as AVAssetTrack
            try trackAudio.insertTimeRange(CMTimeRangeMake(kCMTimeZero, frameDuration),
                                   of: curAudio, at: kCMTimeZero)
            try trackVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero, frameDuration),
                                   of: curVideo, at: kCMTimeZero)
        }
        catch
        {
            print("PetShare: ERROR - Could not compose video!")
            return nil
        }
        
        let completeMovie = getDocumentsDirectory() + "/PetBabelMerged.mov"
        completionFlag = 0
        let completeMovieUrl = URL(fileURLWithPath: completeMovie)
        
        if FileManager.default.fileExists(atPath: completeMovie)
        {
            do
            {
                try FileManager.default.removeItem(atPath: completeMovie)
            }
            catch
            {
                print("PetShare: ERROR - Unable to delete shared video file!")
                return nil
            }
        }
        
        let exporter = AVAssetExportSession(asset: composition,
                                            presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = completeMovieUrl
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.exportAsynchronously(
        completionHandler: {
            completionFlag = 1
        })
        
        while completionFlag == 0
        {
            
        }
        
        switch exporter.status
        {
            case  AVAssetExportSessionStatus.failed:
                print("PetShare: ERROR - Exporter failed composition!")
                return nil
            case AVAssetExportSessionStatus.cancelled:
                print("PetShare: ERROR - Exporter was canceled!")
                return nil
            default:
                print("PetShare: Movie export completed without issue!")
        }

        return completeMovieUrl
    
    }
    
    /* Creates the asset writer for converting the image and audio into a 
        meme */
    func createAssetWriter(_ path: String, size: CGSize) -> AVAssetWriter?
    {
        let pathURL = URL(fileURLWithPath: path)
        
        do {
            let newWriter = try AVAssetWriter(outputURL: pathURL, fileType: AVFileTypeMPEG4)
            
            let videoSettings: [String : AnyObject] =
                [
                    AVVideoCodecKey  : AVVideoCodecH264 as AnyObject,
                    AVVideoWidthKey  : size.width as AnyObject,
                    AVVideoHeightKey : size.height as AnyObject,
                ]
            
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            newWriter.add(assetWriterVideoInput)
            
            print("PetShare: Created asset writer for \(size.width)x\(size.height) video")
            return newWriter
        } catch
        {
            print("PetShare: ERROR - Creating asset writer: \(error)")
            return nil
        }
    }
    
    /* Appends a UIImage into a pixes buffer so that we can pass it into AssetWriter */
    func appendPixelBufferForImageAtURL(_ image: UIImage,
                                        pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
                                        presentationTime: CMTime) -> Bool
    {
        var appendSucceeded = false
        
        autoreleasepool {
            if  let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool
            {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                if let pixelBuffer = pixelBufferPointer.pointee , status == 0
                {
                    fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                    appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    pixelBufferPointer.deinitialize()
                }
                else
                {
                    print("PetShare: ERROR - Failed to allocate pixel buffer from pool")
                }
                
                pixelBufferPointer.deallocate(capacity: 1)
            }
        }
        
        return appendSucceeded
    }
    
    /* Actually populates pixel buffer with UIImage */
    func fillPixelBufferFromImage(_ image: UIImage, pixelBuffer: CVPixelBuffer)
    {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
    
    /* Function that returns common path as a string to the documents directory */
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                        .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    /* Sets up the meme creation */
    func createVideoFromImage(_ image: UIImage!, translation: NSString!)
    {
        /* Text Variables */
        let fontColor: UIColor = referencedController.curColor
        let curTrans: PetTranslation = referencedController.referencedController.curTrans

        let atPoint: CGPoint = CGPoint(x: image.size.width/6,
                                       y: image.size.height/3)
        let scale = UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(image.size, false,
                                               scale)
        
        let fontStyle: UIFont = UIFont(name: "Chalkboard SE",
                                       size: image.size.width/12)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraphStyle.alignment = NSTextAlignment.center
        
        /* Setting up the font */
        let textFontAttributes =
            [
                NSFontAttributeName: fontStyle,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName:paragraphStyle,
            ]
        
        /* Put the image into a rectangle as large as the original image. */
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        /* Creating a point within the space that is as bit as the image. */
        let rect: CGRect = CGRect(x: atPoint.x, y: atPoint.y,
                                      width: image.size.width - atPoint.x * 2,
                                      height: image.size.height)
        
        /* Now Draw the text into an image. */
        translation.draw(in: rect, withAttributes: textFontAttributes)
        
        /* Create a new image out of the images we have created */
        imagePreview.image =  UIGraphicsGetImageFromCurrentImageContext()
        
        /* End the context now that we have the image we need */
        UIGraphicsEndImageContext()
        
        let videoPath = getDocumentsDirectory() + "/petBabel.mp4"
        
        if FileManager.default.fileExists(atPath: videoPath)
        {
            do
            {
                try FileManager.default.removeItem(atPath: videoPath)
            }
            catch
            {
                print("PetShare: ERROR - Unable to delete shared video file!")
                return
            }
        }
        
        let completeVideoURL = convertImagetoPetMovie(imagePreview.image!,
                                                      videoPath: videoPath,
                                                      duration: curTrans.duration,
                                                      audioURL: curTrans.audioURL! as URL)
        
        
        if completeVideoURL == nil
        {
            return
        }
        
        self.savedVideo = completeVideoURL!
        activityIndicator.stopAnimating()
        playVideoAction(playGesture)
        
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        
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
        
            /* Load the ad from Facebook */
            fullSiteAd = FBInterstitialAd(placementID: "556114377906938_559362917582084")
            fullSiteAd.delegate = self
            fullSiteAd.load()
        }
        else
        {
            bottomMargin.constant = 10
            createVideoFromImage(referencedController.petImage.image,
                                 translation: referencedController.translationTextField.text as NSString!)
        }

        self.assetURL = ""
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Intersitital Ad
    func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd)
    {
        print("PetShare: Interstitial ad did load")
        fullSiteAd.show(fromRootViewController: self)
    }
    
    func interstitialAd(_ interstitialAd: FBInterstitialAd,
                        didFailWithError error: Error)
    {
        print("PetShare: Interstitial ad did not load")
    }
    
    func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd)
    {
        createVideoFromImage(referencedController.petImage.image,
                             translation: referencedController.translationTextField.text as NSString!)
    }
    
}

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

class VideoPreviewViewController: UIViewController
{
    // MARK: Variables
    var referencedController: ImageShareViewController!
    var savedVideo: NSURL!
    
    // MARK: Video generation
    var writer: AVAssetWriter!
    
    // MARK: Properties
    @IBOutlet weak var imagePreview: UIImageView!
    
    
    // MARK: Functions
    func convertImagetoPetMovie(petImage: UIImage, videoPath: String,
                                duration: Float, audioURL: NSURL) -> NSURL?
    {
        /* Create AVAssetWriter to write video */
        guard let assetWriter = createAssetWriter(videoPath, size: petImage.size) else
        {
            print("Error converting images to video: AVAssetWriter not created")
            return nil
        }
        
        /* Create AVAssetWriterInputPixelBufferAdaptor */
        let writerInput = assetWriter.inputs.filter{ $0.mediaType == AVMediaTypeVideo }.first!
        let sourceBufferAttributes : [String : AnyObject] =
            [
                kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String : petImage.size.width,
                kCVPixelBufferHeightKey as String : petImage.size.height,
            ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput,
                                                                      sourcePixelBufferAttributes: sourceBufferAttributes)
        
        /* Start writing session */
        assetWriter.startWriting()
        assetWriter.startSessionAtSourceTime(kCMTimeZero)
        if (pixelBufferAdaptor.pixelBufferPool == nil)
        {
            print("Error converting images to video: pixelBufferPool nil after starting session")
            return nil
        }
        
        // -- Set video parameters
        var frameDuration = kCMTimeZero
        var completionFlag = 0

        /* Writing a frame at the beginning to start the write */
        if !appendPixelBufferForImageAtURL(petImage, pixelBufferAdaptor: pixelBufferAdaptor,
                                           presentationTime: frameDuration)
        {
            print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
            return nil
        }
        
        /* Writing one frame at the end to make the length */
        frameDuration = CMTimeMake(Int64(ceil(duration)),1)
        if !appendPixelBufferForImageAtURL(petImage, pixelBufferAdaptor: pixelBufferAdaptor,
                                           presentationTime: frameDuration)
        {
            print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
            return nil
        }
        
        writerInput.markAsFinished()
        assetWriter.finishWritingWithCompletionHandler
            {
                print("Recording finished!")
                completionFlag = 1
        }
        
        while completionFlag != 1
        {
            
        }
        
        /* Now merging the audio and video */
        let composition = AVMutableComposition()
        let trackVideo:AVMutableCompositionTrack =
            composition.addMutableTrackWithMediaType(AVMediaTypeVideo,
                                                     preferredTrackID: CMPersistentTrackID())
        let trackAudio:AVMutableCompositionTrack =
            composition.addMutableTrackWithMediaType(AVMediaTypeAudio,
                                                     preferredTrackID: CMPersistentTrackID())
        let videoURL = NSURL(fileURLWithPath: videoPath)
        let sourceVideo = AVURLAsset(URL: videoURL, options: nil)
        let sourceAudio = AVURLAsset(URL: audioURL, options: nil)
        
        let audioTracks = sourceAudio.tracksWithMediaType(AVMediaTypeAudio)
        let videoTracks = sourceVideo.tracksWithMediaType(AVMediaTypeVideo)
        
        if audioTracks.count == 0 || videoTracks.count == 0
        {
            print("ERROR: Could not compose video")
            return nil
        }
        
        do
        {
            let curAudio = audioTracks[0] as AVAssetTrack
            let curVideo = videoTracks[0] as AVAssetTrack
            try trackAudio.insertTimeRange(CMTimeRangeMake(kCMTimeZero, frameDuration),
                                   ofTrack: curAudio, atTime: kCMTimeZero)
            try trackVideo.insertTimeRange(CMTimeRangeMake(kCMTimeZero, frameDuration),
                                   ofTrack: curVideo, atTime: kCMTimeZero)
        }
        catch
        {
            print("ERROR: Could not compose video!")
            return nil
        }
        
        let completeMovie = getDocumentsDirectory() + "/PetBabelMerged.mov"
        completionFlag = 0
        let completeMovieUrl = NSURL(fileURLWithPath: completeMovie)
        
        if NSFileManager.defaultManager().fileExistsAtPath(completeMovie)
        {
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(completeMovie)
            }
            catch
            {
                print("Unable to delete share video file!")
                return nil
            }
        }
        
        let exporter = AVAssetExportSession(asset: composition,
                                            presetName: AVAssetExportPresetHighestQuality)!
        exporter.outputURL = completeMovieUrl
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.exportAsynchronouslyWithCompletionHandler(
        {
            completionFlag = 1
        })
        
        while completionFlag == 0
        {
            
        }
        
        switch exporter.status
        {
            case  AVAssetExportSessionStatus.Failed:
                print("Exporter failed composition!")
                return nil
            case AVAssetExportSessionStatus.Cancelled:
                print("Exporter was canceled!")
                return nil
            default:
                print("Movie export completed without issue!")
        }

        return completeMovieUrl
    
    }
    
    
    func createAssetWriter(path: String, size: CGSize) -> AVAssetWriter?
    {
        // Convert <path> to NSURL object
        let pathURL = NSURL(fileURLWithPath: path)
        
        // Return new asset writer or nil
        do {
            // Create asset writer
            let newWriter = try AVAssetWriter(URL: pathURL, fileType: AVFileTypeMPEG4)
            
            // Define settings for video input
            let videoSettings: [String : AnyObject] =
                [
                    AVVideoCodecKey  : AVVideoCodecH264,
                    AVVideoWidthKey  : size.width,
                    AVVideoHeightKey : size.height,
                ]
            
            // Add video input to writer
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
            newWriter.addInput(assetWriterVideoInput)
            
            // Return writer
            print("Created asset writer for \(size.width)x\(size.height) video")
            return newWriter
        } catch
        {
            print("Error creating asset writer: \(error)")
            return nil
        }
    }
    
    
    func appendPixelBufferForImageAtURL(image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool
    {
        var appendSucceeded = false
        
        autoreleasepool {
            if  let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool
            {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.alloc(1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                if let pixelBuffer = pixelBufferPointer.memory where status == 0
                {
                    fillPixelBufferFromImage(image, pixelBuffer: pixelBuffer)
                    appendSucceeded = pixelBufferAdaptor.appendPixelBuffer(pixelBuffer, withPresentationTime: presentationTime)
                    pixelBufferPointer.destroy()
                } else {
                    NSLog("Error: Failed to allocate pixel buffer from pool")
                }
                
                pixelBufferPointer.dealloc(1)
            }
        }
        
        return appendSucceeded
    }
    
    
    func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBufferRef)
    {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0)
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create CGBitmapContext
        let context = CGBitmapContextCreate(
            pixelData,
            Int(image.size.width),
            Int(image.size.height),
            8,
            CVPixelBufferGetBytesPerRow(pixelBuffer),
            rgbColorSpace,
            CGImageAlphaInfo.PremultipliedFirst.rawValue
        )
        
        // Draw image into context
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0)
    }
    
    func getDocumentsDirectory() -> String
    {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func createVideoFromImage(image: UIImage!, translation: NSString!)
    {
        /* Text Variables */
        let fontColor: UIColor = UIColor.whiteColor()
        let curTrans: PetTranslation = referencedController.referencedController.curTrans

        let atPoint: CGPoint = CGPoint(x: image.size.width/6, y: image.size.height/2)
        let scale = UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
        let fontStyle: UIFont = UIFont(name: "Chalkboard SE", size: image.size.width/12)!
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        
        /* Setting up the font */
        let textFontAttributes =
            [
                NSFontAttributeName: fontStyle,
                NSForegroundColorAttributeName: fontColor,
                NSParagraphStyleAttributeName:paragraphStyle,
            ]
        
        /* Put the image into a rectangle as large as the original image. */
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        /* Creating a point within the space that is as bit as the image. */
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y,
                                      image.size.width - atPoint.x * 2,
                                      image.size.height)
        
        /* Now Draw the text into an image. */
        translation.drawInRect(rect, withAttributes: textFontAttributes)
        
        /* Create a new image out of the images we have created */
        imagePreview.image =  UIGraphicsGetImageFromCurrentImageContext()
        
        /* End the context now that we have the image we need */
        UIGraphicsEndImageContext()
        
        let videoPath = getDocumentsDirectory().stringByAppendingString("/petBabel.mp4")
        
        if NSFileManager.defaultManager().fileExistsAtPath(videoPath)
        {
            do
            {
                try NSFileManager.defaultManager().removeItemAtPath(videoPath)
            }
            catch
            {
                print("Unable to delete share video file!")
                return
            }
        }
        
        let completeVideoURL = convertImagetoPetMovie(imagePreview.image!, videoPath: videoPath,
                                  duration: curTrans.duration,
                                  audioURL: curTrans.audioURL!)
        
        if completeVideoURL == nil
        {
            return
        }
        
        let player = AVPlayer(URL: completeVideoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.presentViewController(playerViewController, animated: true)
        {
            playerViewController.player!.play()
        }
        
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        createVideoFromImage(referencedController.petImage.image,
                             translation: referencedController.translationTextField.text)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

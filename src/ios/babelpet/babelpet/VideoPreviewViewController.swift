//
//  VideoPreviewViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/28/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit

class VideoPreviewViewController: UIViewController
{
    // MARK: Variables
    var referencedController: ImageShareViewController!
    
    // MARK: Properties
    @IBOutlet weak var imagePreview: UIImageView!
    
    
    // MARK: Functions
    func createVideoFromImage(image: UIImage!, translation: NSString!)
    {
        /* Text Variables */
        let fontColor: UIColor = UIColor.whiteColor()
        let fontStyle: UIFont = UIFont(name: "Chalkboard SE", size: 25)!
        let atPoint: CGPoint = CGPoint(x: image.size.width/6, y: image.size.height/2)
        
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
        
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
        
        //Put the image into a rectangle as large as the original image.
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y,
                                      image.size.width - atPoint.x * 2,
                                      image.size.height)
        
        //Now Draw the text into an image.
        translation.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        imagePreview.image =  UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()

        
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

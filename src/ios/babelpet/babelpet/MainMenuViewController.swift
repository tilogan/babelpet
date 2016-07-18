//
//  MainMenuViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/17/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController
{
    // MARK: Properties
    @IBOutlet weak var petToHumanImage: UIImageView!
    @IBOutlet weak var humanToPetImage: UIImageView!
    
    
    override func viewDidLoad()
    {
        petToHumanImage.layer.borderWidth = 2
        petToHumanImage.layer.borderColor = UIColor(red: 0.224, green: 0.243, blue: 0.968, alpha: 1.0).CGColor

        humanToPetImage.layer.borderWidth = 2
        humanToPetImage.layer.borderColor = UIColor(red: 0.224, green: 0.243, blue: 0.968, alpha: 1.0).CGColor

        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewWillDisappear(animated)
    }
}

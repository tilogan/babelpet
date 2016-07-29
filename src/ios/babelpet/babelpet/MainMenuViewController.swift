//
//  MainMenuViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/17/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit
import iAd

class MainMenuViewController: UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.canDisplayBannerAds = true
        super.canDisplayBannerAds = true
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

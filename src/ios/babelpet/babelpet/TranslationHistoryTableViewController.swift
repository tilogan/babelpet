//
//  TranslationHistoryTableViewController.swift
//  babelpet
//
//  Created by Timothy Logan on 7/17/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit

class TranslationHistoryTableViewController: UITableViewController
{
    // MARK: Variables
    var referencedController: BabelPetViewController!
   
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int
    {
         return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return referencedController.translations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "TranslationTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                         for: indexPath) as! TranslationTableViewCell
        let translation = referencedController.translations[(indexPath as NSIndexPath).row]

        cell.translationHeading.text = translation.description

        return cell
    }

    /* Override to support conditional editing of the table view. */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        /* Return false if you do not want the specified item to be editable. */
        return true
    }

    /* Override to support editing the table view. */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            let translationToDelete: PetTranslation! = referencedController.translations[(indexPath as NSIndexPath).row]
            
            /* If they are deleting the current translation, we have to reset the
                view */
            if referencedController.curTrans != nil &&
                referencedController.curTrans.isEqual(translationToDelete)
            {
                referencedController.translationLabel.text = "Press Record to Start!"
                referencedController.playBackButton.isEnabled = false
                referencedController.shareButton.isEnabled = false
            }
            
            referencedController.translations.remove(at: (indexPath as NSIndexPath).row)
            referencedController.saveTranslations()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        referencedController.curTrans = referencedController.translations[(indexPath as NSIndexPath).row]
        referencedController.translationLabel.text = referencedController.curTrans.translatedText
        referencedController.playBackButton.isEnabled = true
        referencedController.shareButton.isEnabled = true
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        tableView.backgroundColor = UIColor(red: 87/255, green: 187/255, blue: 250/255, alpha: 1.0)
    }
}

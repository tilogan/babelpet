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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
         return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return referencedController.translations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cellIdentifier = "TranslationTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier,
                         forIndexPath: indexPath) as! TranslationTableViewCell
        let translation = referencedController.translations[indexPath.row]

        cell.translationHeading.text = translation.description

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete
        {
            referencedController.translations.removeAtIndex(indexPath.row)
            referencedController.saveTranslations()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert
        {
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        referencedController.curTrans = referencedController.translations[indexPath.row]
        referencedController.translationLabel.text = referencedController.curTrans.translatedText
        referencedController.playBackButton.enabled = true
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        tableView.backgroundColor = UIColor(red: 87/255, green: 187/255, blue: 250/255, alpha: 1.0)
    }
}

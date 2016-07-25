//
//  TranslationTableViewCell.swift
//  babelpet
//
//  Created by Timothy Logan on 7/24/16.
//  Copyright © 2016 Shintako LLC. All rights reserved.
//

import UIKit

class TranslationTableViewCell: UITableViewCell
{
    // MARK: Properties
    @IBOutlet weak var translationHeading: UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

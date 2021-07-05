//
//  MovieDetailOverviewTableViewCell.swift
//  The Movie Database
//
//  Created by Diego Henrique on 01/07/21.
//

import UIKit

class MovieDetailOverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  LocationTableViewCell.swift
//  Roam
//
//  Created by Samuel Fox on 12/27/18.
//
//

import UIKit
import MapKit

class LocationTableViewCell: UITableViewCell {

    var location : MKMapItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

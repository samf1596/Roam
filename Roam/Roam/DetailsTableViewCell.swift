//
//  DetailsTableViewCell.swift
//  Roam
//
//  Created by Samuel Fox on 1/26/19.
//
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var detailTextView: UITextView!
    
    func adjustTextViewHeight(textview : UITextView) {
        textview.translatesAutoresizingMaskIntoConstraints = true
        textview.sizeToFit()
        textview.isScrollEnabled = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  DestinationMessageCell.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/05/10.
//

import UIKit

class DestinationMessageCell: UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var imageview_profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

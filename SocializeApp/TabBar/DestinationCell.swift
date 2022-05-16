//
//  DestinationCell.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/05/10.
//

import UIKit

class DestinationCell: UITableViewCell {
    
    @IBOutlet weak var label_message: UILabel!
    @IBOutlet weak var imageview_profile: UIImageView!
    @IBOutlet weak var label_name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label_message.layer.masksToBounds = true
        label_message.layer.cornerRadius = label_message.frame.height / 5
        imageview_profile.layer.masksToBounds = true
        imageview_profile.layer.cornerRadius = imageview_profile.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: false)

        // Configure the view for the selected state
    }

}

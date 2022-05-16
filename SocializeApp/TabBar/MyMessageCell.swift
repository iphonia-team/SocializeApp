//
//  MyMessageCell.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/05/10.
//

import UIKit

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    
    //@IBOutlet weak var message_blue: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        label_message.layer.masksToBounds = true
        label_message.layer.cornerRadius = label_message.frame.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

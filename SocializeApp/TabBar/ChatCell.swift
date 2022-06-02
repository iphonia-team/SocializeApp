//
//  ChatCell.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/09.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var chatContentsLabel: UILabel!
    
    @IBOutlet weak var chatDateLabel: UILabel!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = userImageView.frame.height/3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

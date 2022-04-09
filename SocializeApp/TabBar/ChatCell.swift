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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

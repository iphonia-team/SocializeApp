//
//  UserListCell.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/12.
//

import UIKit

class UserListCell: UITableViewCell {
    @IBOutlet weak var userListImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var teachingLabel: UILabel!
    
    @IBOutlet weak var learningLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        self.userListImageView.layer.cornerRadius = (self.userListImageView.frame.size.height)/2
//        self.userListImageView.clipsToBounds = true
//    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

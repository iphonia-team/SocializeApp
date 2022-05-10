//
//  MyMessageCell.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/05/10.
//

import UIKit

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var label_message: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CommentCell.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/05/16.
//

import UIKit
import FirebaseFirestore

protocol CommentCellDelegate {
    func tapMoreButton(index: Int)
}

class CommentCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    var delegate: CommentCellDelegate?
    var index = 0
    var email = ""
    var communityName = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func tapMoreButton(_ sender: UIButton) {
        self.delegate?.tapMoreButton(index: self.index)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

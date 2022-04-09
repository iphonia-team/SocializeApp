//
//  ChatListViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/09.
//

import UIKit

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatListTableView.delegate = self
        self.chatListTableView.dataSource = self
    }
        
}

extension ChatListViewController: UITableViewDelegate {
    
}

extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
                as? ChatCell else { return UITableViewCell() }
        cell.userNameLabel.text = "Conor McGregor"
        cell.chatContentsLabel.text = "What kind of music do you like and what app do you use?"
        cell.chatDateLabel.text = "7:11 PM"
        cell.userImageView.image = UIImage(named: "chatUserImage")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatRoomViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else { return }
        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
    }
    
    
}

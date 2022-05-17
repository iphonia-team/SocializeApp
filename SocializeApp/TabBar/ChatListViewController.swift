//
//  ChatListViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/09.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatListViewController: UIViewController {

    @IBOutlet weak var chatListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatListTableView.delegate = self
        self.chatListTableView.dataSource = self
    }
    
    func getMessageList() {
        print("@@!!getMessageList")
        database.collection("chatRooms").addSnapshotListener{ snapshot, error in
            self.comments = []
            debugPrint("----------------------")
            if let err = error {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                for doc in documents {
                    if (doc.documentID == self.chatRoomUid) {
                        guard let data = doc.data()["comments"] as? [[String: Any]] else {
                            print("not Convert!!!")
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            return
                            
                        }
                        print("doc.data()[comments]: \(data)")

                        for index in data {
                            guard let uid = index["uid"] as? String else { return }
                            guard let message = index["message"] as? String else { return }
                            guard let date = index["date"] as? String else { return }
                            self.comments.append(Comment(uid: uid, message: message, date: date))
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.tableView.scrollToRow(at: IndexPath(row: self.comments.count-1, section: 0), at: .top, animated: false)
                        }
                        print("@@@@@self.comments: \(self.comments[0])")
                    }
                }
            }
        }
    }
        
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
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

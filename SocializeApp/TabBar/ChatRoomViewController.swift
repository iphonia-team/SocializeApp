//
//  ChatRoomViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/09.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var uid: String?
    var chatRoomUid: String?
    var comments: [Comment]?
    
    
    var destinationUid: String?
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uid = Auth.auth().currentUser?.uid
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
        checkChatRoom()
    }
    
    @objc func createRoom() {
        let createRoomInfo = [
            "users": [
                "uid": uid,
                "destinationUid": destinationUid
            ]
        ]
        if(chatRoomUid == nil) {
            self.sendButton.isEnabled = false
            self.database.collection("chatRooms").document().setData(createRoomInfo) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    self.checkChatRoom()
                    print("Document successfully written!")
                }
                
            }
        } else {
            let comment = [
                "uid": uid!,
                "message": messageTextField.text!,
                "date": String(Date().timeIntervalSince1970)
            ] as [String: Any]
            self.database.collection("chatRooms").document(chatRoomUid!).updateData([
                "comments":FieldValue.arrayUnion([comment])
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    print("comments successfully written!")
                }
            }
        }
    }
    func checkChatRoom() {
        database.collection("chatRooms")
            .whereField("users.uid", isEqualTo: uid!)
            .whereField("users.destinationUid", isEqualTo: destinationUid!)
            .getDocuments{ snapshot, err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                for item in documents {
                    self.chatRoomUid = item.documentID
                    self.sendButton.isEnabled = true
                    print(self.chatRoomUid!)
                    self.getMessageList()
                }
            }
        }
    }
    
    func getMessageList() {
        print("@@!!getMessageList")
        database.collection("chatRooms").addSnapshotListener{ snapshot, error in
            self.comments = []
            
            if let err = error {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                let decoder = JSONDecoder()
                for doc in documents {
                    do {
                        if (doc.documentID == self.chatRoomUid) {
                            guard let data = doc.data()["comments"] as? [[String: Any]] else { print("not Convert!!!"); return }
                            print("doc.data()[comments]: \(data)")
                            let count = doc.data().count
                            print(count)

                            for index in data {
                                let uid = index["uid"] as! String
                                let message = index["message"] as! String
                                let date = index["date"] as! String
                                self.comments?.append(Comment(uid: uid, message: message, date: date))
                            }
                            print("@@@@@self.comments: \(self.comments)")
                        }

                    } catch let err {
                        print("##err: \(err.localizedDescription)")
                    }
                    
//                    if (doc.documentID == self.chatRoomUid) {
//                        print("doc.data()['users']: \(doc.data()["users"])")
//                        print("doc.data()['comments']: \(doc.data()["message"])")
//                        let dic = doc.data() as? [String: Any]
//                        print("doc.data() as? [String: Any]\(doc.data() as? [String:Any])")
//                        if let messageModel = doc.data()["comments"] as? [String: Any] {
//                            print("@@messageModel: \(messageModel)")
//                            for item in messageModel {
//                                print("@@item: \(item)")
//                                if let uid = item.uid as? String,
//                                    let message = item.message as? String,
//                                   let date = item.date as? String {
//                                    self.comments?.append(Comment(uid: uid, message: message, date: date))
//                                }
//                            }
//                        }
//                    }
                }
            }
        }
    }
    
}

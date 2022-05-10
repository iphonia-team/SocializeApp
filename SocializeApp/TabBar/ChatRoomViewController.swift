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
    var comments: [Comment] = []
    var userModel: User?
    
    
    var destinationUid: String?
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.delegate = self
        //self.tableView.dataSource = self
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
                    self.getDestinationInfo()
                }
            }
        }
    }
    
    func getDestinationInfo() {
        print("getDestinationInfo()")
        database.collection("users")
            .whereField("uid", isEqualTo: self.destinationUid!)
            .getDocuments { snapshot, err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    self.userModel = User()
                    if let documents = snapshot?.documents {
                        for document in documents {
                            do {
                                let data = document.data()
                                let jsonData = try JSONSerialization.data(withJSONObject: data)
                                
                                let decoder = JSONDecoder()
                                let profile = try decoder.decode(User.self, from: jsonData)
                                
                                self.userModel = profile
                                print("@@@self.userModel : \(self.userModel)")
                                self.getMessageList()
                                
                            } catch {
                                print(error)
                            }
                    }
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
                for doc in documents {
                    if (doc.documentID == self.chatRoomUid) {
                        guard let data = doc.data()["comments"] as? [[String: Any]] else { print("not Convert!!!"); return }
                        print("doc.data()[comments]: \(data)")
                        let count = doc.data().count
                        print(count)

                        for index in data {
                            let uid = index["uid"] as! String
                            let message = index["message"] as! String
                            let date = index["date"] as! String
                            self.comments.append(Comment(uid: uid, message: message, date: date))
                        }
                        print("@@@@@self.comments: \(self.comments)")
                    }
                }
            }
        }
    }
    
}

//extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        self.comments.count
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
//        //cell
//    }
//    
//}

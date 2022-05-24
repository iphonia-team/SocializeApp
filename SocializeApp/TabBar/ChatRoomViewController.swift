//
//  ChatRoomViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/09.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var uid: String?
    var chatRoomUid: String?
    var comments: [Comment] = []
    var userModel: User = User()
    
    
    var destinationUid: String?
    var destinationName: String?
    
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = destinationName
        uid = Auth.auth().currentUser?.uid
        self.checkChatRoom(completion: self.sendMessage, completion2: self.getDestinationInfo)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorColor = UIColor.clear
        self.tableView.keyboardDismissMode = .onDrag
        sendButton.addTarget(self, action: #selector(createRoom), for: .touchUpInside)
    }
    
    @objc func createRoom() {
        let createRoomInfo = [
            "users": [
                uid: true,
                destinationUid: true
            ]
        ]
        if(chatRoomUid == nil) {
            self.sendButton.isEnabled = false
            self.database.collection("chatRooms").document().setData(createRoomInfo) { err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    self.checkChatRoom(completion: self.sendMessage, completion2: self.getDestinationInfo)
                    print("Document successfully written!")
                }
            }
        }
        else {
            self.sendMessage()
        }
    }
    func sendMessage() {
        if (self.messageTextField.text != "") {
            let comment = [
                "uid": uid!,
                "message": messageTextField.text!,
                "date": String(Date().timeIntervalSince1970)
            ] as [String: Any]
            if let key = self.chatRoomUid {
                print("chatRoomUid \(self.chatRoomUid as String?)")
                self.database.collection("chatRooms").document(key).updateData([
                    "comments":FieldValue.arrayUnion([comment])
                ]) { err in
                    if let err = err {
                        print("Error writing document: \(err.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.messageTextField.text = ""
                        }
                        print("comments successfully written!")
                    }
                }
            }
                else {print("!!!No chatRoomUid")}
        }
        
    }
    func checkChatRoom(completion: @escaping () -> Void, completion2: @escaping () -> Void) {
        print("@@checkChatRoom")
        database.collection("chatRooms")
            .whereField("users.\(self.uid!)", isEqualTo: true)
            .whereField("users.\(self.destinationUid!)", isEqualTo: true)
            .getDocuments{ snapshot, err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                for item in documents {
                    self.chatRoomUid = item.documentID
                    self.sendButton.isEnabled = true
                    print(self.chatRoomUid!)
                }
            }
            completion()
                
        }
        completion2()
        //self.getDestinationInfo()
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
                                
                                
                            } catch {
                                print(error)
                            }
                    }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        self.getMessageList()
                }
            }
        }
    }
    
    func getMessageList() {
        print("@@!!getMessageList")
        database.collection("chatRooms")
            .addSnapshotListener{ snapshot, error in
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

extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if(self.comments[indexPath.row].uid == uid) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as? MyMessageCell else { return UITableViewCell() }
            cell.label_message.text = self.comments[indexPath.row].message
            cell.label_message.numberOfLines = 0
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell", for: indexPath) as? DestinationCell else { return UITableViewCell() }
            //cell.label_name.text = userModel.name
            cell.label_message.text = self.comments[indexPath.row].message
            cell.label_message.numberOfLines = 0
            
            if let profileImage = self.userModel.imageUrl {
                FirebaseStorageManager.downloadImage(urlString: profileImage) { image in
                    cell.imageview_profile.image = image
                }
            } else {
                cell.imageview_profile.image = UIImage(named: "default-profile-image")
            }
            cell.selectionStyle = UITableViewCell.SelectionStyle.none            
            return cell
        }
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.allowsSelection = false
//        tableView.deselectRow(at: indexPath, animated: false)
//    }
    
    
}

//extension ChatRoomViewController: UITextFieldDelegate {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return true
//    }
//}

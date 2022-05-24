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
    let database = Firestore.firestore()
    var uid: String?
    var chatRoomUid: [String] = []
    var comments: [Comment] = []
    var userModel: [User] = []
    
    //내 uid가 포함 되어있는 채팅방의 users 필드값 받아올 배열
    var users: Array = [[String:Any]]()//[Dictionary<String,Any>] = [[:]]
    var otherUIDs: [String] = [] // 나와 채팅기록이 있는 상대방들의 uid 저장
    
    var chatListCells: [ChatListCell] = []
    var Cells: [ChatListCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uid = Auth.auth().currentUser?.uid
        self.getRoom {
            self.getContents {
                self.getComments()
            }
        }
        self.chatListTableView.delegate = self
        self.chatListTableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getChatRoomUid()
    }
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidApper!!!")
        self.getRoom {
            self.getContents {
                self.getComments()
            }
        }
    }
    
// https://hcn1519.github.io/articles/2017-09/swift_escaping_closure
    func getRoom(completion: @escaping () -> Void) {
        print("@@ getRoom : ")
        database.collection("chatRooms")
            .whereField("users.\(self.uid!)", isEqualTo: true)
            .getDocuments { snapshot, err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    self.otherUIDs = []
                    self.users = []
                    guard let documents = snapshot?.documents else { return }
                    for doc in documents {
                        self.users.append(doc.data()["users"] as! Dictionary<String, Any>)
                    }
                    print("@@@@@ self.users : \(self.users)")
                    for item in self.users {
                        var user = item
                        user.removeValue(forKey: self.uid!)
                        for key in user.keys {
                            let uid = key as String
                            self.otherUIDs.append(uid)
                        }
                    }
                    print("@@@ otherUIDs : \(self.otherUIDs)")
                }
                DispatchQueue.main.async {
                    self.chatListTableView.reloadData()
                }
                completion()
        }
        
        
    }
    func getChatRoomUid() {
        print("@@ getChatRoomUid @@")
        database.collection("chatRooms")
            .whereField("users.\(self.uid!)", isEqualTo: true)
            .getDocuments{ snapshot, err in
                
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    self.chatRoomUid = []
                    guard let documents = snapshot?.documents else { return }
                    for item in documents {
                        self.chatRoomUid.append(item.documentID)
                    }
                    print("@@self.chatRoomUid: \(self.chatRoomUid)")
                }
                DispatchQueue.main.async {
                    self.chatListTableView.reloadData()
                }
            }
    }
    
    func getContents(completion: @escaping () -> Void) {
        print("@@ getContents @@")
        database.collection("users").addSnapshotListener { snapshot, err in
            if let err = err {
                print("Error writing document: \(err.localizedDescription)")
            } else {
                guard let documents = snapshot?.documents else { return }
                self.userModel = []
                for item in documents {
                    let data = item.data()
                    print("@@@data['uid']\(data["uid"])")
                    for uid in self.otherUIDs { //otheruid가 없음 이시점에
                        print("@@@otherUIDs for문")
                        if (data["uid"] as! String == uid) {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: data)
                                let decoder = JSONDecoder()
                                let profile = try decoder.decode(User.self, from: jsonData)
                                self.userModel.append(profile)
                                print("@@self.userModel : \(self.userModel)")
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                        } else {print("no same uid!!!!!!!!!!!!!")}
                    }
                }
            }
            completion()
        }
        DispatchQueue.main.async {
            self.chatListTableView.reloadData()
        }
    }
    
    func getComments() {
        print("@@@getComments")
        database.collection("chatRooms")
            .whereField("users.\(self.uid!)", isEqualTo: true)
            .addSnapshotListener{ snapshot, err in
                if let err = err {
                    print("Error writing document: \(err.localizedDescription)")
                } else {
                    self.chatListCells = []
                    guard let documents = snapshot?.documents else { print("getComments - cannot get Documents"); return }
                    for doc in documents {
                        for key in self.chatRoomUid{
                            if (doc.documentID == key) {
                                guard var userData = doc.data()["users"] as? Dictionary<String, Any> else {
                                    print("getComments - cannot get userData")
                                    return
                                }
                                guard let commentsData = doc.data()["comments"] as? [[String: Any]] else {
                                    print("getComments - cannot get commentsData")
                                    return
                                }
                                userData.removeValue(forKey: self.uid!)
                                let dID = userData.keys.first! as String
                                print(dID)
                                print(commentsData.last)
                                
                                
                                for model in self.userModel {
                                    if (model.uid == dID) {
                                        let key = doc.documentID
                                        let destinationUid = model.uid
                                        let imageUrl = model.imageUrl
                                        let name = model.name
                                        let nationalityCode = model.nationalityCode ?? ""
                                        let content = (commentsData.last?["message"] ?? "") as! String
                                        guard var date = (commentsData.last?["date"])! as? String else { return }
                                        date = self.dateFormatter(stringDate: date)
                                        self.chatListCells.append(ChatListCell(key: key, destinationUid: destinationUid, imageUrl: imageUrl, name: name, nationalityCode: nationalityCode, content: content, date: date))
                                        print(self.chatListCells)
                                    }
                                    DispatchQueue.main.async {
                                        self.chatListTableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
        
    }
    
    func dateFormatter(stringDate: String) -> String {
        let unixTime = Double(stringDate) ?? 0.0
        let date = Date(timeIntervalSince1970: unixTime).formatted(date: .omitted, time: .shortened)
        return date
    }
    
    func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
}
    
    

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatListCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
                as? ChatCell else { return UITableViewCell() }
        cell.userNameLabel.text = "\(self.chatListCells[indexPath.row].name ?? "") \(flag(country: self.chatListCells[indexPath.row].nationalityCode ?? ""))"
        cell.chatContentsLabel.text = self.chatListCells[indexPath.row].content
        cell.chatDateLabel.text = self.chatListCells[indexPath.row].date
        if let profileImage = self.chatListCells[indexPath.row].imageUrl {
            FirebaseStorageManager.downloadImage(urlString: profileImage) { image in
                cell.userImageView.image = image
            }
        } else {
            cell.userImageView.image = UIImage(named: "default-profile-image")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chatRoomViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else { return }
        chatRoomViewController.destinationUid = self.chatListCells[indexPath.row].destinationUid
        chatRoomViewController.destinationName = self.chatListCells[indexPath.row].name
        self.navigationController?.pushViewController(chatRoomViewController, animated: true)
        self.chatListTableView.deselectRow(at: indexPath, animated: true)
    }    
    
}


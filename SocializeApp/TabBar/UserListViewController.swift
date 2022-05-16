//
//  UserListViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/11.
//

import UIKit
import Firebase

class UserListViewController: UIViewController {

    @IBOutlet weak var userListTableView: UITableView!
    
    var users: [User] = []
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userListTableView.dataSource = self
        self.userListTableView.delegate = self
        self.configureUserList()

    }

    private func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    
    private func configureUserList() {
        database.collection("users").addSnapshotListener { (snapshot, error) in
            self.users = []
            
            if let e = error {
                print(e.localizedDescription)
            } else {
                let myUid = Auth.auth().currentUser?.uid
                if let snapshotDocuments = snapshot?.documents {
                    for document in snapshotDocuments {
                        do {
                            let data = document.data()
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            
                            let decoder = JSONDecoder()
                            let profile = try decoder.decode(User.self, from: jsonData)
                            
                            if (profile.uid == myUid) {
                                continue
                            }
                            
                            self.users.append(profile)
                            DispatchQueue.main.async {
                                self.userListTableView.reloadData()
                            }
                            print(self.users)
                            
                        } catch {
                            print(error)
                        }
                    }
                }
                
            }
        }
    }


}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath)
                as? UserListCell else { return UITableViewCell() }
        
        cell.userNameLabel.text = self.users[indexPath.row].name
        cell.countryLabel.text = "from \(flag(country: self.users[indexPath.row].nationalityCode!))"
        cell.teachingLabel.text = self.users[indexPath.row].teachingLanguage
        cell.learningLabel.text = self.users[indexPath.row].learningLanguage
        
        //cell.userListImageView.image = UIImage(named: "ConorMcgregor")
//
//        let image = UIImage(named: "ConorMcgregor")
        
        if let profileImage = self.users[indexPath.row].imageUrl {
            FirebaseStorageManager.downloadImage(urlString: profileImage) { image in
                cell.userListImageView.image = image
            }
        } else {
            cell.userListImageView.image = UIImage(named: "default-profile-image")
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .alert)
        let chatButton = UIAlertAction(title: "1:1 Chat", style: .default, handler: { [weak self] _ in
            guard let chatRoomViewController = self?.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else { return }
            chatRoomViewController.destinationUid = self?.users[indexPath.row].uid
            chatRoomViewController.destinationName = self?.users[indexPath.row].name
            self?.navigationController?.pushViewController(chatRoomViewController, animated: true)
        })
        let deleteButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        deleteButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(chatButton)
        alert.addAction(deleteButton)
        tableView.deselectRow(at: indexPath, animated: true)
        self.present(alert, animated: true, completion: nil)
    }
    
}

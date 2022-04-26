//
//  UserListViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/11.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class UserListViewController: UIViewController {

    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userListTableView.dataSource = self
        self.userListTableView.delegate = self
        
        DispatchQueue.main.async {
            TabBarController.loadUsersData()
        }
        self.userListTableView.reloadData()

    }

    private func flag(country:String) -> String {
        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }


}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TabBarController.users.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath)
                as? UserListCell else { return UITableViewCell() }
        
        cell.userNameLabel.text = TabBarController.users[indexPath.row].name
        cell.countryLabel.text = "from \(flag(country: TabBarController.users[indexPath.row].nationalityCode!))"
        cell.teachingLabel.text = TabBarController.users[indexPath.row].teachingLanguage
        cell.learningLabel.text = TabBarController.users[indexPath.row].learningLanguage
        
        //cell.userListImageView.image = UIImage(named: "ConorMcgregor")
//
//        let image = UIImage(named: "ConorMcgregor")
        
        if let profileImage = TabBarController.users[indexPath.row].imageUrl {
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
            self?.navigationController?.pushViewController(chatRoomViewController, animated: true)
        })
        let deleteButton = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        deleteButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(chatButton)
        alert.addAction(deleteButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

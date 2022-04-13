//
//  UserListViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/11.
//

import UIKit

class UserListViewController: UIViewController {

    @IBOutlet weak var userListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userListTableView.dataSource = self
        self.userListTableView.delegate = self
        
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

extension UserListViewController: UITableViewDelegate {
    
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath)
                as? UserListCell else { return UITableViewCell() }
        cell.userNameLabel.text = "Conor McGregor"
        cell.countryLabel.text = self.flag(country: "IE")
        //cell.userListImageView.image = UIImage(named: "ConorMcgregor")
        
        let image = UIImage(named: "ConorMcgregor")
        cell.userListImageView.image = image

        let itemSize = CGSize.init(width: 40, height: 40) // your custom size
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale);
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell.userListImageView.image!.draw(in: imageRect)
        cell.userListImageView.image! = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext()

        cell.userListImageView.layer.cornerRadius = (itemSize.width) / 2
        cell.userListImageView.clipsToBounds = true
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Action", message: nil, preferredStyle: .alert)
        let chatButton = UIAlertAction(title: "1:1 Chat", style: .default, handler: { [weak self] _ in
            guard let chatRoomViewController = self?.storyboard?.instantiateViewController(withIdentifier: "ChatRoomViewController") as? ChatRoomViewController else { return }
            self?.navigationController?.pushViewController(chatRoomViewController, animated: true)
        })
        let deleteButton = UIAlertAction(title: "delete", style: .default, handler: nil)
        deleteButton.setValue(UIColor.red, forKey: "titleTextColor")
        alert.addAction(chatButton)
        alert.addAction(deleteButton)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

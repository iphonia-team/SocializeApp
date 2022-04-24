//
//  SettingsViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var universityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let db = Firestore.firestore()
    let currentUser = Auth.auth().currentUser
    let list = ["Edit Profile", "Change Profile Image", "Log Out"]
    
    var user = User()
    let imagePickerController = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        imagePickerController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLabels()
    }
    
    private func updateLabels() {
        
        let userInfo = db.collection("users").document(currentUser?.email ?? "")

        userInfo.getDocument { document, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(User.self, from: jsonData)
                    
                    self.user = profile
                    self.nameLabel.text = profile.name
                    self.emailLabel.text = profile.email
                    
                    if let profileImage = profile.imageUrl {
                        FirebaseStorageManager.downloadImage(urlString: profileImage) { [weak self] image in
                            self?.profileImageView.image = image
                        }
                    }
                } catch {
                    print(error)
                }
                
                    
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
}

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let item = self.list[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = item
        cell.contentConfiguration = content
        
        return cell
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.list[indexPath.row]
        
        if item == "Log Out" {
            let refreshAlert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                do {
                    try Auth.auth().signOut()
                } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                }
                
                self.dismiss(animated: true)
            }))

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default))

            present(refreshAlert, animated: true, completion: nil)
            
        } else if item == "Edit Profile" {
            guard let editProfileViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileViewController")
                    as? EditProfileViewController else { return }
            
            editProfileViewController.user = self.user
            editProfileViewController.modalPresentationStyle = .formSheet
            self.present(editProfileViewController, animated: true, completion: nil)
        } else if item == "Change Profile Image" {
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let img = info[UIImagePickerController.InfoKey.originalImage] {
            profileImageView.image = img as? UIImage
            guard let selectedImage = img as? UIImage else { return }
            FirebaseStorageManager.uploadImage(image: selectedImage, pathRoot: user.email!) { url in
                if let url = url {
                    
                    let db = Firestore.firestore()
                    let document = db.collection("users").document(self.user.email!)
                    
                    document.updateData([
                        "imageUrl": url.absoluteString
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        } else {
                            let alert = UIAlertController(title: "Good", message: "Profile successfully updated!", preferredStyle: UIAlertController.Style.alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default)
                            alert.addAction(alertAction)
                            self.present(alert,animated: true,completion: nil)
                        }
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}

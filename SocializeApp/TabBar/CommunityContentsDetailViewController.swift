//
//  CommunityContentsDetailViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/05/16.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CommunityContentsDetailViewController: UIViewController {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsLabel: UILabel!
    @IBOutlet weak var likecountLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var commentsTableView: UITableView!
    
    var contentEmail = ""
    var contentTime = ""
    var communityName = ""
    let db = Firestore.firestore()
    var postInfo = Post()
    var postComments = [PostComment]()
    var currentUser = Auth.auth().currentUser
    var user = User()
    var likeUsers = [LikeUser]()
    
    private var keyboardIsOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentsTableView.delegate = self
        self.commentsTableView.dataSource = self
        self.sendButton.isEnabled = false
        self.configureInputField()
        self.loadMyInfo()
        self.setPullDownButton()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setPullDownButton() {
        let editPost = UIAction(title: "Edit Post", image: UIImage(systemName: "pencil"), handler: { _ in
            guard let editPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditPostViewController")
                    as? EditPostViewController else { return }
            
            editPostViewController.titleString = self.titleLabel.text!
            editPostViewController.contentString = self.contentsLabel.text!
            editPostViewController.timeString = self.timeLabel.text!
            editPostViewController.emailString = self.postInfo.email!
            editPostViewController.communityName = self.communityName
            self.navigationController?.pushViewController(editPostViewController, animated: true)
        })
        
        let deletePost = UIAction(title: "Delete Post", image: UIImage(systemName: "delete.left"), handler: { _ in
            let refreshAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                self.db.collection("\(self.communityName)Room").document("\(self.contentTime)-\(self.contentEmail)").delete() { err in
                    if let err = err {
                        print("Error removing document: \(err)")
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }))

            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default))

            self.present(refreshAlert, animated: true, completion: nil)
        })
        self.moreButton.menu = UIMenu(identifier: nil,
                                      options: .displayInline,
                                      children: [editPost, deletePost])
    }
    
    private func isMyPostOrNot() {
        if postInfo.email != currentUser?.email {
            self.moreButton.isHidden = true
        }
    }
    
    private func loadMyInfo() {
        
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
                    
                } catch {
                    print(error)
                }
                
                    
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func loadContentsData() {
        let docRef = db.collection("\(self.communityName)Room").document("\(self.contentTime)-\(contentEmail)")
        
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let post = try decoder.decode(Post.self, from: jsonData)
                    
                    self.postInfo = post
                    self.authorLabel.text = self.postInfo.author
                    self.timeLabel.text = self.postInfo.postTime
                    self.titleLabel.text = self.postInfo.title
                    self.contentsLabel.text = self.postInfo.content
                    self.likecountLabel.text = String(self.postInfo.likeCount!)
                    
                } catch {
                    print(error)
                }
            } else {
                print("Document does not exist")
            }
        }
        
        let userRef = self.db.collection("users").document("\(self.contentEmail)")
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(User.self, from: jsonData)
                    
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
        
        self.likeUsers = [LikeUser]()
        
        docRef.collection("likeUsers").getDocuments { querySnapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            for document in querySnapshot!.documents {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let likeUser = try decoder.decode(LikeUser.self, from: jsonData)
                    
                    self.likeUsers.append(likeUser)
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    private func loadCommentsData() {
        self.postComments = [PostComment]()
        
        let docRef = db.collection("\(self.communityName)Room").document("\(self.contentTime)-\(contentEmail)").collection("comments")
        
        docRef.getDocuments() { querySnapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            for document in querySnapshot!.documents {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let postComment = try decoder.decode(PostComment.self, from: jsonData)
                    
                    self.postComments.append(postComment)
                    
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func tapMoreButton(_ sender: UIButton) {
        
    }
    @IBAction func tapLikeButton(_ sender: UIButton) {
        
        let docRef = db.collection("\(self.communityName)Room").document("\(self.contentTime)-\(contentEmail)")
        
        if sender.isSelected {
            sender.isSelected = false
            docRef.updateData([
                "likeCount" : self.postInfo.likeCount! - 1
            ])
            
            docRef.collection("likeUsers").document("\(self.user.email!)").delete()
            
        } else {
            sender.isSelected = true
            docRef.updateData([
                "likeCount" : self.postInfo.likeCount! + 1
            ])
            
            docRef.collection("likeUsers").document("\(self.user.email!)").setData([
                "email" : self.user.email!
            ])
        }
        
        self.loadContentsData()
    }
    @IBAction func tapSendButton(_ sender: UIButton) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let current_date_string = formatter.string(from: Date())
        
        let docRef = db.collection("\(self.communityName)Room").document("\(self.contentTime)-\(contentEmail)")
        
        docRef.collection("comments").document("\(current_date_string)-\(self.user.email!)").setData([
            "name" : self.user.name!,
            "content" : self.commentTextField.text!,
            "date" : current_date_string,
            "email" : self.user.email!
        ])
        
        self.commentTextField.text = ""
        
        docRef.updateData([
            "commentCount" : self.postInfo.commentCount! + 1
        ])
        
        DispatchQueue.main.async {
            self.loadCommentsData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.commentsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.loadContentsData()
            self.loadCommentsData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.isMyPostOrNot()
            for likeUser in self.likeUsers {
                if likeUser.email == self.user.email! {
                    self.likeButton.isSelected = true
                }
            }
            self.commentsTableView.reloadData()
        }
    }
    
    private func configureInputField() {
        self.commentTextField.addTarget(self, action: #selector(self.commentTextFieldDidChange), for: .editingChanged)
        
    }
    
    @objc private func commentTextFieldDidChange() {
        self.sendButton.isEnabled = !(self.commentTextField.text?.isEmpty ?? true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CommunityContentsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
                as? CommentCell else { return UITableViewCell() }
        
        cell.nameLabel.text = self.postComments[indexPath.row].name
        cell.timeLabel.text = self.postComments[indexPath.row].date
        cell.contentLabel.text = self.postComments[indexPath.row].content
        cell.email = self.postComments[indexPath.row].email!
        cell.communityName = self.communityName
        cell.delegate = self
        cell.index = indexPath.row
        if self.postComments[indexPath.row].email! != currentUser?.email {
            cell.moreButton.isHidden = true
        }
        return cell
    }
}

extension CommunityContentsDetailViewController: CommentCellDelegate {
    func tapMoreButton(index: Int) {
        let refreshAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete?", preferredStyle: UIAlertController.Style.alert)
        
        let docRef = db.collection("\(self.communityName)Room").document("\(self.contentTime)-\(contentEmail)")
        
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
            docRef.updateData([
                "commentCount" : self.postInfo.commentCount! - 1
            ])
            
            docRef.collection("comments").document("\(self.postComments[index].date!)-\(self.postComments[index].email!)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    DispatchQueue.main.async {
                        self.loadCommentsData()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.commentsTableView.reloadData()
                    }
                    
                }
            }
        }))

        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default))

        self.present(refreshAlert, animated: true, completion: nil)
    }
    
    
}

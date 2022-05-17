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
            "date" : current_date_string
        ])
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.isMyPostOrNot()
            for likeUser in self.likeUsers {
                if likeUser.email == self.user.email! {
                    self.likeButton.isSelected = true
                }
            }
            self.commentsTableView.reloadData()
        }
        
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    
    private func configureInputField() {
        self.commentTextField.addTarget(self, action: #selector(self.commentTextFieldDidChange), for: .editingChanged)
        
    }
    
    @objc private func commentTextFieldDidChange() {
        self.sendButton.isEnabled = !(self.commentTextField.text?.isEmpty ?? true)
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ noti: NSNotification) {
        if keyboardIsOpened == false {
            self.view.frame.origin.y -= 40
            keyboardIsOpened = true
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        if keyboardIsOpened == true {
            self.view.frame.origin.y += 40
            keyboardIsOpened = false
        }
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
        
        return cell
    }
}

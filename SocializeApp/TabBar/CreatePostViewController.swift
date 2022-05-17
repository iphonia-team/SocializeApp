//
//  CreatePostViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/05/09.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreatePostViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var postButton: UIButton!
    
    var keyboardIsOpened = false
    
    var collectionName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postButton.isEnabled = false
        self.contentTextView.delegate = self
        configureInputField()
        
    }
    
    @IBAction func tapPostButton(_ sender: UIButton) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let current_date_string = formatter.string(from: Date())

        
        let db = Firestore.firestore()
        
        db.collection("\(collectionName)Room").document("\(current_date_string)-\(CommunityViewController.user.email!)").setData([
            "author" : CommunityViewController.user.name!,
            "email" : CommunityViewController.user.email!,
            "postTime" : current_date_string,
            "title": self.titleTextField.text!,
            "content": self.contentTextView.text!,
            "likeCount": 0,
            "commentCount": 0
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func configureInputField() {
        self.titleTextField.addTarget(self, action: #selector(self.inputFieldDidChange), for: .editingChanged)
    }
    
    @objc private func inputFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func validateInputField() {
        self.postButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.contentTextView.text.isEmpty)
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
            self.view.frame.origin.y -= 20
            keyboardIsOpened = true
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        if keyboardIsOpened == true {
            self.view.frame.origin.y += 20
            keyboardIsOpened = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension CreatePostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}

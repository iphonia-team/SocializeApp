//
//  EditPostViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/05/23.
//

import UIKit
import FirebaseFirestore

class EditPostViewController: UIViewController {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    var keyboardIsOpened = false
    var titleString = ""
    var contentString = ""
    var timeString = ""
    var emailString = ""
    var communityName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentTextView.delegate = self
        configureInputField()
        
        self.titleTextField.text = titleString
        self.contentTextView.text = contentString
    }
    
    @IBAction func tapConfirmButton(_ sender: UIButton) {
        
        let db = Firestore.firestore()
        let document = db.collection("\(self.communityName)Room").document("\(self.timeString)-\(self.emailString)")

        document.updateData([
            "title": self.titleTextField.text!,
            "content": self.contentTextView.text!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                let alert = UIAlertController(title: "Good", message: "Done!", preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                    
                }
                alert.addAction(alertAction)
                self.present(alert,animated: true,completion: nil)
            }
        }
    }
    
    private func configureInputField() {
        self.titleTextField.addTarget(self, action: #selector(self.inputFieldDidChange), for: .editingChanged)
    }
    
    @objc private func inputFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.contentTextView.text.isEmpty)
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

extension EditPostViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}

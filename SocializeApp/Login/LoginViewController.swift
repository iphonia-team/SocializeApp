//
//  LoginViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/07.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    var keyboardIsOpened = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.isEnabled = false
        configureInputField()
    }
    
    @IBAction func tapLoginButton(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] authResult, error in
            
            guard let strongSelf = self else { return }
            
            // 에러 처리
            if authResult == nil {
                let alert = UIAlertController(title: "Error", message: "Invalid Email or Wrong Password", preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(alertAction)
                strongSelf.present(alert,animated: true,completion: nil)
            } else {
                guard let tabBarController = strongSelf.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                        as? TabBarController else { return }
                
                tabBarController.modalPresentationStyle = .fullScreen
                strongSelf.present(tabBarController, animated: true, completion: nil)
            }
        }
        
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        self.addKeyboardNotifications()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.removeKeyboardNotifications()
//    }
    
    private func configureInputField() {
        self.emailTextField.addTarget(self, action: #selector(self.emailTextFieldDidChange(_:)), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.passwordTextFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func passwordTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func validateInputField() {
        self.loginButton.isEnabled = !(self.emailTextField.text?.isEmpty ?? true) && !(self.passwordTextField.text?.isEmpty ?? true)
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
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardIsOpened == false {
                self.view.frame.origin.y -= 100
                keyboardIsOpened = true
            }
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            if keyboardIsOpened == true {
                self.view.frame.origin.y += 100
                keyboardIsOpened = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

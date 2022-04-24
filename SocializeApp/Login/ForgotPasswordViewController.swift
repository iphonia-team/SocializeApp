//
//  ForgotPasswordViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/08.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        okButton.isEnabled = false
        configureTextField()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func configureTextField() {
        self.emailTextField.addTarget(self, action: #selector(self.emailTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        self.okButton.isEnabled = !(self.emailTextField.text?.isEmpty ?? true)
    }
    
    @IBAction func tapOKButton(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!) { error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: "Invalid Email.", preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert,animated: true,completion: nil)

            } else {
                let alert = UIAlertController(title: "Success", message: "Check Your Email!", preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert,animated: true,completion: nil)
                print(self.emailTextField.text!)
            }
        }
    }
    
}

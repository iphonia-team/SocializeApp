//
//  RegisterViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/08.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerButton.isEnabled = false
        self.configureInputField()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapRegisterButton(_ sender: UIButton) {
    }
    
    private func configureInputField() {
        self.emailTextField.addTarget(self, action: #selector(self.emailTextFieldDidChange), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(self.nameTextFieldDidChange), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.passwordTextFieldDidChange), for: .editingChanged)
        self.confirmPasswordTextField.addTarget(self, action: #selector(self.confirmPasswordTextFieldDidChange), for: .editingChanged)
    }
    
    @objc private func emailTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func nameTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func passwordTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    @objc private func confirmPasswordTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func validateInputField() {
        self.registerButton.isEnabled = !(self.emailTextField.text?.isEmpty ?? true) && !(self.nameTextField.text?.isEmpty ?? true) && !(self.passwordTextField.text?.isEmpty ?? true) && !(self.confirmPasswordTextField.text?.isEmpty ?? true)
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

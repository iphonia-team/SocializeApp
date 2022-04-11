//
//  RegisterViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/08.
//

import UIKit
import Foundation

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    private var keyboardIsOpened = false
    private let pickerView = UIPickerView()
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerButton.isEnabled = false
        self.configureInputField()
        self.configurePickerView()
    }
    
    @IBAction func tapRegisterButton(_ sender: UIButton) {
        user.email = emailTextField.text
        user.name = nameTextField.text
        user.password = passwordTextField.text
        user.nationality = nationalityTextField.text
        let confirmPassword = confirmPasswordTextField.text!
        
        // 패스워드와 패스워드 확인 문자열 비교
        guard user.password == confirmPassword else {
            let alert = UIAlertController(title: "Error", message: "Password and confirmation password are not the same.", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert,animated: true,completion: nil)
            return
        }
        
        // 학교 이메일을 사용했는지 확인
        guard user.email!.contains("ac.kr") else {
            let alert = UIAlertController(title: "Error", message: "Please use your university email.", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert,animated: true,completion: nil)
            return
        }
        
        self.performSegue(withIdentifier: "registerNextSegue", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerNextSegue" {
            if let vc = segue.destination as? ChoosingLanguageViewController {
                vc.user = self.user
            }
        }
    }
    
    private func configureInputField() {
        self.emailTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.nameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.confirmPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    private func configurePickerView() {
        self.pickerView.delegate = self
        self.nationalityTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.nationalityTextField.inputView = self.pickerView
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }
    
    private func validateInputField() {
        self.registerButton.isEnabled = !(self.emailTextField.text?.isEmpty ?? true) && !(self.nameTextField.text?.isEmpty ?? true) && !(self.passwordTextField.text?.isEmpty ?? true) && !(self.confirmPasswordTextField.text?.isEmpty ?? true) && !(self.nationalityTextField.text?.isEmpty ?? true)
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
            self.view.frame.origin.y -= 120
            keyboardIsOpened = true
        }
    }
    
    @objc func keyboardWillHide(_ noti: NSNotification) {
        if keyboardIsOpened == true {
            self.view.frame.origin.y += 120
            keyboardIsOpened = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

extension RegisterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Countries.countryList.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Countries.countryList[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.nationalityTextField.text = Countries.countryList[row]
        self.nationalityTextField.sendActions(for: .editingChanged)
    }
    
}

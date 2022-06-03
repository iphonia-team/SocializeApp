//
//  RegisterViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/08.
//

import UIKit
import Foundation
import CountryPickerView

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var countryPicker: UITextField!
    
    private var keyboardIsOpened = false
    //private let pickerView = UIPickerView()
    var user = User()
    var nationalityCode: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerButton.isEnabled = false
        self.configureInputField()
        self.configurePickerView()
        self.configureCountryPickerView()
    }
    
    @IBAction func tapRegisterButton(_ sender: UIButton) {
        user.email = emailTextField.text
        user.name = nameTextField.text
        user.nationality = nationalityTextField.text
        user.nationalityCode = self.nationalityCode// 추가부분
        
        // 패스워드와 패스워드 확인 문자열 비교
        guard passwordTextField.text! == confirmPasswordTextField.text! else {
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
        
        if let emailSuffix = user.email?.components(separatedBy: "@")[1] {
            user.university = emailSuffix.components(separatedBy: ".")[0]
        }
        
        
        self.performSegue(withIdentifier: "registerNextSegue", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerNextSegue" {
            if let vc = segue.destination as? ChoosingLanguageViewController {
                vc.user = self.user
                vc.password = self.passwordTextField.text!
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
        //self.pickerView.delegate = self
        self.nationalityTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        //self.nationalityTextField.inputView = self.pickerView
    }
    //추가부분
    private func configureCountryPickerView() {
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 32, height: 34))
        cpv.delegate = self
        cpv.dataSource = self
        self.countryPicker.leftView = cpv
        cpv.showPhoneCodeInView = false
        cpv.showCountryNameInView = false
        cpv.showPhoneCodeInView = false
        self.countryPicker.leftViewMode = .always
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func validateInputField() {
        self.registerButton.isEnabled = !(self.emailTextField.text?.isEmpty ?? true) && !(self.nameTextField.text?.isEmpty ?? true) && !(self.passwordTextField.text?.isEmpty ?? true) && !(self.confirmPasswordTextField.text?.isEmpty ?? true) && !(self.nationalityTextField.text?.isEmpty ?? true)
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
// 추가 부분
extension RegisterViewController: CountryPickerViewDelegate, CountryPickerViewDataSource {
    func searchBarPosition(in countryPickerView: CountryPickerView) -> SearchBarPosition {
        return .hidden
    }
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        self.nationalityCode = country.code
        self.nationalityTextField.text = country.name
        self.nationalityTextField.sendActions(for: .editingChanged)
    }
}

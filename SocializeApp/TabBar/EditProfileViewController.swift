//
//  EditProfileViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/24.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class EditProfileViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nationalityTextField: UITextField!
    @IBOutlet weak var teachingTextField: UITextField!
    @IBOutlet weak var learningTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    private var keyboardIsOpened = false
    private let nationalityPickerView = UIPickerView()
    private let teachingPickerView = UIPickerView()
    private let learningPickerView = UIPickerView()
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton.isEnabled = false
        self.configureInputField()
        self.configurePickerView()
        self.setInfo()
    }
    
    private func setInfo() {
        self.nameTextField.text = self.user.name
        self.nationalityTextField.text = self.user.nationality
        self.teachingTextField.text = self.user.teachingLanguage
        self.learningTextField.text = self.user.learningLanguage
    }
    
    @IBAction func tapDoneButton(_ sender: UIButton) {
        
        let db = Firestore.firestore()
        let document = db.collection("users").document(self.user.email!)

        document.updateData([
            "name": self.nameTextField.text!,
            "nationality": self.nationalityTextField.text!,
            "learningLanguage": self.learningTextField.text!,
            "teachingLanguage": self.teachingTextField.text!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                let alert = UIAlertController(title: "Good", message: "Profile successfully updated!", preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.dismiss(animated: true)
                    
                }
                alert.addAction(alertAction)
                self.present(alert,animated: true,completion: nil)
            }
        }
        
    }
    
    private func configureInputField() {
        self.nameTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.nationalityTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.teachingTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.learningTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
    }
    
    private func configurePickerView() {
        self.nationalityPickerView.delegate = self
        self.teachingPickerView.delegate = self
        self.learningPickerView.delegate = self
        self.nationalityTextField.inputView = self.nationalityPickerView
        self.teachingTextField.inputView = self.teachingPickerView
        self.learningTextField.inputView = self.learningPickerView
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        self.validateInputField()
    }
    
    private func validateInputField() {
        self.doneButton.isEnabled = !(self.nameTextField.text?.isEmpty ?? true) && !(self.nationalityTextField.text?.isEmpty ?? true) && !(self.teachingTextField.text?.isEmpty ?? true) && !(self.learningTextField.text?.isEmpty ?? true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.nationalityPickerView {
            return Countries.countryList.count
        } else {
            return Countries.languageList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.nationalityPickerView {
            return Countries.countryList[row]
        } else {
            return Countries.languageList[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.nationalityPickerView {
            self.nationalityTextField.text = Countries.countryList[row]
            self.nationalityTextField.sendActions(for: .editingChanged)
        } else if pickerView == self.teachingPickerView {
            self.teachingTextField.text = Countries.languageList[row]
            self.teachingTextField.sendActions(for: .editingChanged)
        } else {
            self.learningTextField.text = Countries.languageList[row]
            self.learningTextField.sendActions(for: .editingChanged)
        }
    }
}

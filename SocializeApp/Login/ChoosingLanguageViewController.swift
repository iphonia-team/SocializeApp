//
//  ChoosingLanguageViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/11.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChoosingLanguageViewController: UIViewController {
    
    @IBOutlet weak var teachingTextField: UITextField!
    @IBOutlet weak var learningTextField: UITextField!
    @IBOutlet weak var univLocTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let teachingPickerView = UIPickerView()
    let learningPickerView = UIPickerView()
    let univLocPickerVIew = UIPickerView()
    
    var user = User()
    var password = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        teachingPickerView.tag = 1
        learningPickerView.tag = 2
        univLocPickerVIew.tag = 3
        doneButton.isEnabled = false
        configurePickerView()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapDoneButton(_ sender: UIButton) {
        
        self.user.learningLanguage = learningTextField.text
        self.user.teachingLanguage = teachingTextField.text
        self.user.univLocation = univLocTextField.text
        
        // Firebase에 User 생성
        Auth.auth().createUser(withEmail: user.email!, password: self.password) { authResult, error in
            if let error = error {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(alertAction)
                self.present(alert,animated: true,completion: nil)
            }
            
            // user 생성되었는지 확인
            guard (authResult?.user) != nil else {
                return
            }
            
            // 완료 alert 발생
            let alert = UIAlertController(title: "Good", message: "Please Login!", preferredStyle: UIAlertController.Style.alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
                
            }
            alert.addAction(alertAction)
            self.present(alert,animated: true,completion: nil)
            
            // Firestore에 사용자 정보 저장
            let db = Firestore.firestore()
            
            db.collection("users").document(self.user.email!).setData([
                "uid" : authResult?.user.uid,
                "email" : self.user.email!,
                "name" : self.user.name!,
                "university": self.user.university!,
                "nationality" : self.user.nationality!,
                "nationalityCode" : self.user.nationalityCode!,
                "teachingLanguage" : self.user.teachingLanguage!,
                "learningLanguage" : self.user.learningLanguage!,
                "univLocation" : self.user.univLocation!
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func configurePickerView() {
        self.teachingPickerView.delegate = self
        self.learningPickerView.delegate = self
        self.univLocPickerVIew.delegate = self
        self.teachingTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.learningTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.univLocTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        self.teachingTextField.inputView = self.teachingPickerView
        self.learningTextField.inputView = self.learningPickerView
        self.univLocTextField.inputView = self.univLocPickerVIew
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.doneButton.isEnabled = !(self.teachingTextField.text?.isEmpty ?? true) && !(self.learningTextField.text?.isEmpty ?? true) && !(self.univLocTextField.text?.isEmpty ?? true)
    }

}

extension ChoosingLanguageViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 3 {
            return Countries.univLocList.count
        } else {
            return Countries.languageList.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 3 {
            return Countries.univLocList[row]
        } else {
            return Countries.languageList[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.teachingTextField.text = Countries.languageList[row]
            self.teachingTextField.sendActions(for: .editingChanged)
        } else if pickerView.tag == 2 {
            self.learningTextField.text = Countries.languageList[row]
            self.learningTextField.sendActions(for: .editingChanged)
        } else {
            self.univLocTextField.text = Countries.univLocList[row]
            self.univLocTextField.sendActions(for: .editingChanged)
        }
    }
    
}

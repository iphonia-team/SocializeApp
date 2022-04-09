//
//  LoginViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/07.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func tapLoginButton(_ sender: UIButton) {
        print("tap")
        guard let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarController")
                as? TabBarController else { return }
        
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true, completion: nil)
        print("tap")
    }
}

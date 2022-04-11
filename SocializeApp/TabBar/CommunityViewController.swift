//
//  CommunityViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/10.
//

import UIKit
import FirebaseAuth

class CommunityViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapUserInfo(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        if let user = user {
            let email = user.email
            print(email)
            try? Auth.auth().signOut()
        }
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

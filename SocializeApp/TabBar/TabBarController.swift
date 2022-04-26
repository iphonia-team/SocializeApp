//
//  TabBarController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/09.
//

import UIKit
import FirebaseFirestore

class TabBarController: UITabBarController {
    
    static var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUsersData()
    }
    
    private func loadUsersData() {
        
        let db = Firestore.firestore()
        
        let userInfo = db.collection("users")
        
        userInfo.getDocuments() { querySnapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            for document in querySnapshot!.documents {
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(User.self, from: jsonData)
                    
                    TabBarController.users.append(profile)
                    
                } catch {
                    print(error)
                }
            }
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

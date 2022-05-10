//
//  CommunityViewController.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/04/10.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommunityViewController: UIViewController {

    @IBOutlet weak var univButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    
    static var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bringInfo()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "univCommunitySegue" {
            if let vc = segue.destination as? CommunityContentsViewController {
                vc.communityName = CommunityViewController.user.university!.uppercased()
            }
        } else if segue.identifier == "countryCommunitySegue" {
            if let vc = segue.destination as? CommunityContentsViewController {
                vc.communityName = CommunityViewController.user.nationality!.uppercased()
            }
        }
    }
    
    private func bringInfo() {
        let db = Firestore.firestore()
        let currentUser = Auth.auth().currentUser
        let userInfo = db.collection("users").document(currentUser?.email ?? "")

        userInfo.getDocument { document, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                
                do {
                    let data = document.data()
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    
                    let decoder = JSONDecoder()
                    let profile = try decoder.decode(User.self, from: jsonData)
                    
                    CommunityViewController.user = profile
                    
                    
                } catch {
                    print(error)
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }

}

//
//  CommunityContentsViewController.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/25.
//

import UIKit
import FirebaseFirestore

class CommunityContentsViewController: UIViewController {

    @IBOutlet weak var communityNameLabel: UILabel!
    @IBOutlet weak var contentsTableView: UITableView!
    var communityName = ""
    
    var posts = [Post]()
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contentsTableView.dataSource = self
        self.contentsTableView.delegate = self
        
        communityNameLabel.text = communityName
        contentsTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.loadCommunityData()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.contentsTableView.reloadData()
        }
    }
    
    @objc func refresh() {
        posts = [Post]()
        self.contentsTableView.reloadData()
    }
    
    @IBAction func tapAddButton(_ sender: UIButton) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "postSegue" {
            if let vc = segue.destination as? CreatePostViewController {
                vc.collectionName = self.communityName.lowercased()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
            DispatchQueue.main.async {
                self.loadCommunityData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.contentsTableView.reloadData()
            }
        }
    }
    
    private func loadCommunityData() {
        
        posts = [Post]()
        
        let db = Firestore.firestore()
        
        let userInfo = db.collection("\(communityName.lowercased())Room")
        
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
                    let post = try decoder.decode(Post.self, from: jsonData)
                    
                    self.posts.insert(post, at: 0)
                    
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

extension CommunityContentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityContentsCell", for: indexPath)
                as? CommunityContentsCell else { return UITableViewCell() }
        
        cell.titleLabel.text = posts[indexPath.row].title
        cell.contentsLabel.text = posts[indexPath.row].content
        cell.likeCountLabel.text = String(posts[indexPath.row].likeCount!)
        cell.commentCountLabel.text = String(posts[indexPath.row].commentCount!)
        
        
        return cell
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    
}

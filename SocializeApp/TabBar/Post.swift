//
//  Post.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/05/10.
//

import Foundation

struct Post: Codable {
    var author: String?
    var email: String?
    var postTime: String?
    var title: String?
    var content: String?
    var likeCount: Int?
    var commentCount: Int?
}

//
//  User.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/11.
//

import Foundation

struct User: Codable {
    
    var uid: String?
    var name: String?
    var email: String?
    var university: String?
    var teachingLanguage: String?
    var learningLanguage: String?
    var nationality: String?
    var nationalityCode: String?
    var imageUrl: String?
    var univLocation: String?
}

struct LikeUser: Codable {
    var email: String
}

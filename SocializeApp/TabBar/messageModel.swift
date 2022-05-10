//
//  messageModel.swift
//  SocializeApp
//
//  Created by Whyeon on 2022/05/10.
//

import Foundation
struct MessageModel: Codable {
    var users: Users?
    var comments: [Comment]
}

struct Users: Codable {
    var uid: String?
    var destinationUid: String?
}

struct Comment: Codable {
    var uid: String
    var message: String
    var date: String
    
//    var dic: [String: Any] {
//        return [
//            "uid": uid,
//            "message": message,
//            "date": date
//        ]
//    }
}

struct Messages: Codable {
    var comments: [Comment]?
}


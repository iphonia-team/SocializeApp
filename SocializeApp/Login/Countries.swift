//
//  Countries.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/11.
//

import Foundation

class Countries {
    static let languageList = ["English", "Korean", "Chinese(Mandarin)", "Chinese(Cantonese)", "Japanese", "Spanish", "French", "Portuguese", "German", "Italian", "Russian", "Arabic"]
    static let countryList = Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }
    
    static let univLocList = ["Seoul/Incheon/Gyeonggi", "Gangwon", "Daejeon/Chungcheong", "Daegu/Gyeongbuk", "Busan/Ulsan/Gyeongnam", "Gwangju/Jeolla/Jeju"]
    
}

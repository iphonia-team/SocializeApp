//
//  Countries.swift
//  SocializeApp
//
//  Created by 홍성범 on 2022/04/11.
//

import Foundation

class Countries {
    static let languageList = Locale.isoLanguageCodes.compactMap { Locale.current.localizedString(forLanguageCode: $0) }
    static let countryList = Locale.isoRegionCodes.compactMap { Locale.current.localizedString(forRegionCode: $0) }
}

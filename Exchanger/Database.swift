//
//  Database.swift
//  Exchanger
//
//  Created by Anton on 6/24/19.
//  Copyright © 2019 YAD.agency. All rights reserved.
//

import Foundation
import RealmSwift

class Currencies: Object {
    @objc dynamic var currencyCode = ""
    @objc dynamic var currencyName = ""
}

class favCurrencies: Object {
    @objc dynamic var firstCurrencyCode = ""
    @objc dynamic var firstCurrencyName = ""
    @objc dynamic var secondCurrencyCode = ""
    @objc dynamic var secondCurrencyName = ""
    @objc dynamic var rate = ""
}

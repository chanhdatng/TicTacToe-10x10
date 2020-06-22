//
//  User.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object{

    @objc dynamic var username = ""
    @objc dynamic var fullname = ""
    @objc dynamic var score = 0
    @objc dynamic var access_token = ""
    
    override static func primaryKey() -> String? {
        return "username"
    }
}

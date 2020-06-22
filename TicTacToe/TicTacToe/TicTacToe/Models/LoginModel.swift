//
//  User.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation
import ObjectMapper

//class User: Mappable {
//
//    var username: String?
//    var accessToken: String?
//
//    required init?(map: Map) {
//    }
//
//    func mapping(map: Map) {
//        username <- map["username"]
//        accessToken <- map["accessToken"]
//    }
//}

class LoginResponse: Mappable{
    var username : String?
    var fullname: String?
    var score : Int?
    var access_token: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        fullname <- map["fullname"]
        score <- map["score"]
        access_token <- map["access_token"]
    }
}


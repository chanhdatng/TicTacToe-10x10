//
//  RegisterResponse.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 5/29/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation
import ObjectMapper

class RegisterResponse: Mappable {
    var error: Bool?
    var message: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        error <- map["error"]
        message <- map["message"]
    }

}

class RankingResponse: Mappable {
    var status: Bool?
    var message: String?
    var data: [UserResponse]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        data <- map["data"]
    }
}


class UserResponse: Mappable {
    var username: String?
    var fullname: String?
    var email: String?
    var score: Int?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        username <- map["username"]
        fullname <- map["fullname"]
        email <- map["email"]
        score <- map["score"]
    }
}


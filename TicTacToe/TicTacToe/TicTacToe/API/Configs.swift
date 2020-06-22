//
//  Configs.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation

struct Production {
//    static let BASE_URL : String = "http://localhost:3000/"
    static let BASE_URL : String = "http://172.20.10.3:3000"
}

enum NetworkErrorType {
    case API_ERROR
    case HTTP_ERROR
}

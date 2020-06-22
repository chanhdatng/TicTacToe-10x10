//
//  BaseResponse.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseResponse<T: Mappable>: Mappable {
    var status: Bool?
    var msg: String?
    var data: T?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        status <- map["status"]
        msg <- map["msg"]
        data <- map["data"]
    }

    func checkStatus() -> Bool? {
        return status == true
    }
}


class BaseResponseError {
    var mErrorType: NetworkErrorType!
    var mErrorMessage: String!
    
    init(_ errorType: NetworkErrorType,_ errorMessage: String) {
        mErrorType = errorType
        mErrorMessage = errorMessage
    }
}

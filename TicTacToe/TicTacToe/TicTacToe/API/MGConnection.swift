//
//  MGConnection.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import SwiftyJSON

class MGConnection {
    
    static func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    static func request<T: Mappable>(_ apiRouter: APIRouter,_ returnType: T.Type, completion: @escaping (_ result: T?, _ error: BaseResponseError?) -> Void) {
        if !isConnectedToInternet() {
            // Xử lý khi lỗi kết nối internet
            print("=====LOG=====> ERROR INTERNET")
            return
        }

        Alamofire.request(apiRouter).responseObject {(response: DataResponse<BaseResponse<T>>) in
            switch response.result {
            case .success:
                if response.response?.statusCode == 200 {
                    if (response.result.value?.checkStatus())! {
                        completion((response.result.value?.data), nil)
                    } else {
                        let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.API_ERROR, (response.result.value?.msg)!)
                        completion(nil, err)
                    }
                } else {
                    let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, "Request is error!")
                    completion(nil, err)
                }
                break
                
            case .failure(let error):
                if error is AFError {
                    let err: BaseResponseError = BaseResponseError.init(NetworkErrorType.HTTP_ERROR, "Server is down ! Request is error!")
                    completion(nil, err)
                }
                
                break
            }
        }
    }
}

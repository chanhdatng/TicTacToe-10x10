//
//  APIRouter.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    // BEGIN DEFINE API
    case login(username : String, password: String)
    case signup(Username: String, Password: String, Email: String, Fullname: String)
    case ranking
    // END DEFINE API

    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .signup:
            return .post
        case .ranking:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .login:
            return "api/login"
        case .signup:
            return "user/register"
        case .ranking:
            return "api/ranking"
        }
    }
    
    // MARK: - Headers
//    private var headers: HTTPHeaders {
//        var headers = ["Accept" : "application/json"]
//        switch self {
//        case .login:
//            break
//        default:
//            break
//        }
//    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .login(let username, let password):
            return [
                "username": username,
                "password": password
            ]
        case .signup( let Username, let Password, let Email, let Fullname):
            return [
                "Username": Username,
                "Password": Password,
                "Email": Email,
                "Fullname": Fullname
            ]
        case .ranking:
            return nil
    }
    }

    
    // MARK: - URL Request
     func asURLRequest() throws -> URLRequest {
        let url = try Production.BASE_URL.asURL()
        
        // setting PATH
        var urlRequest: URLRequest = URLRequest(url: url.appendingPathComponent(path))
        
        
        // setting method
        urlRequest.httpMethod = method.rawValue
        
        
        // setting header
        
        
        //
        if let parameters = parameters {
            do {
                urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            } catch {
                print("Enconding failed!")
            }
        }
        //
        return urlRequest
       }

}

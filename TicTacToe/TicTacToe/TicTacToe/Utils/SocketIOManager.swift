//
//  SocketIOManager.swift
//  DistributedSystem
//
//  Created by Trương Quốc Tài on 9/27/19.
//  Copyright © 2019 Trương Quốc Tài. All rights reserved.
//

import Foundation
import SocketIO
import SwiftyJSON
import UserNotifications

class SocketIOManager:NSObject{
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    static let shared = SocketIOManager()
    let manager = SocketManager(socketURL: URL(string: Production.BASE_URL)!, config: [.log(true), .compress])
    var socket: SocketIOClient!
    
    
    override init() {
        super.init()
        socket = manager.defaultSocket
    }
    func connectSocket() {
        
        socket.connect()
        socket!.on(clientEvent: .connect) {data, ack in
            self.socket.emit("authenticate", [
                "token" : self.delegate.currentUser.access_token,
                "username": self.delegate.currentUser.username
            ])
        }
        
        socket.on("server-send-arrRooms") { (data, _) in
        let dataJson = JSON(data)
            let dataRoom = dataJson[0]["data"]
            
            let arrRooms = dataRoom["rooms"].arrayObject as? [String]
            self.delegate.listRoom = arrRooms ?? [String]()
        }
    }
    
    func reConnectSocket(){
        print("========RECONNECT=======")
        socket.connect()
    }
    
    func emitServer(_ event: String,_ data:[Any]){
        if checkConnected(self.socket){
            self.socket.emit(event, with: data)
        }
        else{
            self.connectSocket()
        }
    }
    
    func checkConnected(_ socket: SocketIOClient) -> Bool{
        if(socket.status == SocketIOStatus.connected){
            return true
        }
        else{
            return false
        }
    }
}

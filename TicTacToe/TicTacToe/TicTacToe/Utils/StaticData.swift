//
//  StaticData.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/10/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation

class StaticData: NSObject{
    struct nameStoryboard {
        static let nameSB = "Main"
    }

    struct nameVC {
        static let PlayVC = "PlayVC"
        static let HomeVC = "HomeVC"
        static let PickSideVC = "PickSideVC"
        static let RoomVC = "RoomVC"
        static let RankingVC = "RankingVC"
        static let BluetoothVC = "BluetoothVC"
        
        
    }

    struct Socket {
        static let URL_SOCKET = "https://677f55c5.ngrok.io"
    }
}

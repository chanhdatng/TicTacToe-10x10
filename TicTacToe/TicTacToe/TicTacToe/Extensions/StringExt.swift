//
//  StringExt.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import Foundation

extension String{
    func trim() -> String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

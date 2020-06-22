//
//  RoomCell.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/17/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class RoomCell: UICollectionViewCell {

    @IBOutlet weak var lbName: UILabel!
    
    @IBOutlet weak var vContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setName(_ str: String){
        self.lbName.text = str
    }
    

}

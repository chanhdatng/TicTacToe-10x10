//
//  XOCell.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/10/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class XOCell: UICollectionViewCell {

    @IBOutlet weak var imgXO: UIImageView!
    var cellState = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        var cellState = 0
    }
    
    func changeImg(_ img: UIImage){
        self.imgXO.image = img
    }
    
    func setState(_ int: Int){
        self.cellState = int
    }

}

//
//  RankCell.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 5/30/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class RankCell: UITableViewCell {
    
    @IBOutlet weak var lbOrder: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbScore: UILabel!
    
    @IBOutlet weak var imgAva: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imgAva.layer.borderColor = UIColor.flatGray()?.cgColor
        imgAva.layer.borderWidth = CGFloat(0.5)
        
    }
    
    override func layoutSubviews() {
        imgAva.cirle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    func initLayout(){
//        
//    }
    
    func setOrder(_ stt: Int){
        lbOrder.text = "\(stt)"
    }
    
    func setName(_ name: String){
        lbName.text = name
    }
    
    func setScore(_ score: Int){
        lbScore.text = "\(score)"
    }
}

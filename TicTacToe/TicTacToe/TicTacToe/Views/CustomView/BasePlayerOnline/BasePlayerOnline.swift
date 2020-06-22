//
//  BasePlayerOnline.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/16/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class BasePlayerOnline: UIView {
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var vMaskImgPlayer: UIView!
    @IBOutlet weak var vPoint: UIView!
    
    @IBOutlet weak var lbPlayer: UILabel!
    
    @IBOutlet weak var imgPlayer: UIImageView!
    
    @IBOutlet weak var lbScore: UILabel!

    override init(frame: CGRect) {
           super.init(frame: frame)
           self.defaultInit()
           
       }
       
       required init?(coder aDecoder: NSCoder) {
           super.init(coder: aDecoder)
           self.defaultInit()
       }
       
       func defaultInit() {
           let bundle = Bundle(for: BasePlayerOnline.self)
           bundle.loadNibNamed("BasePlayerOnline", owner: self, options: nil)
           self.vContainer.fixInView(self)
            vMaskImgPlayer.cirle()
            imgPlayer.cirle()
            vPoint.cirle()
       }
       
       func setImgPlayer(_ img: UIImage){
           imgPlayer.image = img
       }
       
       func setRotateName(){
           lbPlayer.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
       }
       
       func setNamePlayer(_ name: String){
           lbPlayer.text = name
       }
       
       func setBGColor(_ color: UIColor){
           vContainer.backgroundColor = color
       }
       
       func setNameColor(_ color: UIColor){
           lbPlayer.textColor = color
       }
       
       func setMaskImgPlayerColor(_ color: UIColor){
           vMaskImgPlayer.backgroundColor = color
       }
}

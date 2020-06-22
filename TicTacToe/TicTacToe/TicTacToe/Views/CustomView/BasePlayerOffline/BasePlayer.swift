//
//  BasePlayer.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/15/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class BasePlayer: UIView {
    
    @IBOutlet weak var vContainer: UIView!
    @IBOutlet weak var vMaskImgPlayer: UIView!
    
    @IBOutlet weak var lbPlayer: UILabel!
    
    @IBOutlet weak var imgPlayer: UIImageView!

   // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.defaultInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.defaultInit()
    }
    
    func defaultInit() {
        let bundle = Bundle(for: BasePlayer.self)
        bundle.loadNibNamed("BasePlayer", owner: self, options: nil)
        self.vContainer.fixInView(self)
        vMaskImgPlayer.cirle()
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

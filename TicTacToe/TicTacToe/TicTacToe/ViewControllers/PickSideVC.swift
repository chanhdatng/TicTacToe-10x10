//
//  PickSideVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/12/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class PickSideVC: UIViewController {
    
    @IBOutlet weak var vX: UIView!
    @IBOutlet weak var vO: UIView!
    
    @IBOutlet weak var btnX: UIButton!
    @IBOutlet weak var btnO: UIButton!
    
    @IBOutlet weak var btnConfirm: UIButton!

    var mode = ""
    var yourSide = ""
    var enemySide = ""
    var gamer = 0
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setLayout(vX)
        setLayout(vO)
        
        //SOCKET
//        Utilities.share.connect()
    }
    
    func setLayout(_ view: UIView){
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.white.cgColor
        view.clipsToBounds = true
    }
    
    @IBAction func onX(_ sender: UIButton) {
        vO.backgroundColor = .clear
        vX.backgroundColor = .lightText
        vX.alpha = 1
        vO.alpha = 0.5
        yourSide = "X"
        enemySide = "O"
    }
    
    @IBAction func onO(_ sender: UIButton) {
        vX.backgroundColor = .clear
        vO.backgroundColor = .lightText
        vO.alpha = 1
        vX.alpha = 0.5
        yourSide = "O"
        enemySide = "X"
    }
    
    @IBAction func onConfirm(_ sender: UIButton){
        print("Confirm Pressed")
        let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PlayVC) as! PlayVC
        vc.side1 = self.yourSide
        vc.side2 = self.enemySide
        vc.mode = self.mode
        vc.gamer = 1
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

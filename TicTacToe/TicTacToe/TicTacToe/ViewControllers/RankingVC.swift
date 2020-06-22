//
//  RankingVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 5/30/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit

class RankingVC: UIViewController {
    
    var listUser : [UserResponse]!
    
    @IBOutlet weak var v1: UIView!
    @IBOutlet weak var v2: UIView!
    @IBOutlet weak var v3: UIView!
    @IBOutlet weak var vBg1: UIView!
    @IBOutlet weak var vBg2: UIView!
    @IBOutlet weak var vBg3: UIView!
    
    @IBOutlet weak var lbName1: UILabel!
    @IBOutlet weak var lbName2: UILabel!
    @IBOutlet weak var lbName3: UILabel!
    
    @IBOutlet weak var lbScore1: UILabel!
    @IBOutlet weak var lbScore2: UILabel!
    @IBOutlet weak var lbScore3: UILabel!
    
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var vRank: UIView!
    @IBOutlet weak var tbvRank: UITableView!
    
    @IBOutlet weak var btnBackHome: ButtonGradient!
    
    var listPlayer: [User] = []
    var first = 4
    var top1 : User?
    var top2 : User?
    var top3 : User?
    var list49: [User]?

    override func viewWillLayoutSubviews() {
        v1.roundCorners([.topLeft, .topRight], radius: 8)
        v2.roundCorners([.topLeft, .topRight], radius: 8)
        v3.roundCorners([.topLeft, .topRight], radius: 8)
        
        vRank.roundCorners([.topLeft, .topRight], radius: 32)
    }
    override func viewDidLayoutSubviews() {
        img1.cirle()
        img2.cirle()
        img3.cirle()
        vBg1.cirle()
        vBg2.cirle()
        vBg3.cirle()
        btnBackHome.cirle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initData()
        initLayout()
        
        
    }
    
    func initData(){
        top1 = listPlayer[0]
        top2 = listPlayer[1]
        top3 = listPlayer[2]
        
        list49 = Array(listPlayer[3...8])
    }
    
    func initLayout(){
        self.tbvRank.delegate = self
        self.tbvRank.dataSource = self
        self.tbvRank.register(RankCell.self, forCellReuseIdentifier: "RankCell")
        self.tbvRank.register(UINib(nibName: "RankCell", bundle: nil), forCellReuseIdentifier: "RankCell")
        self.tbvRank.isScrollEnabled = false
        
        img1.image = UIImage(named: "\(Int.random(in: 1...40))")
        img2.image = UIImage(named: "\(Int.random(in: 1...40))")
        img3.image = UIImage(named: "\(Int.random(in: 1...40))")
        
        lbName1.text = top1?.username
        lbName2.text = top2?.username
        lbName3.text = top3?.username
        
        lbScore1.text = "\(String(describing: top1!.score))"
        lbScore2.text = "\(String(describing: top2!.score))"
        lbScore3.text = "\(String(describing: top3!.score))"
    }
    
    @IBAction func pressedBackHome(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

extension RankingVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankCell") as! RankCell
        let user = list49![indexPath.row]
        cell.setName(user.username)
        cell.setScore(user.score)
        cell.setOrder(first)
        first += 1
        cell.imgAva.image = UIImage(named: "\(Int.random(in: 1...40))")
        if first == 10 {
            first = 4
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tbvRank.frame.height/6
    }
    
    
}





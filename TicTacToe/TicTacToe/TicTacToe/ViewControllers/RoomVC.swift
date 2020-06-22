//
//  RoomVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/14/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftIcons
import JJFloatingActionButton
import NVActivityIndicatorView

class RoomVC: UIViewController, NVActivityIndicatorViewable {
    
    
    @IBOutlet weak var clvRoom: UICollectionView!
    @IBOutlet weak var btnCreateRoom: UIButton!
    var listRooms = [String]()
    var currentUser = User()
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    private let refreshControl = UIRefreshControl()
    
    let socket = SocketIOManager.shared.socket!
    let activityData = ActivityData.init(size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE, message: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE, messageFont: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_FONT, messageSpacing: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_SPACING, type: .ballClipRotateMultiple, color: NVActivityIndicatorView.DEFAULT_COLOR, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initActions()
        if #available(iOS 10.0, *){
            self.clvRoom.refreshControl = refreshControl
        } else {
            self.clvRoom.addSubview(refreshControl)
        }
        
        self.refreshControl.addTarget(self, action: #selector(updateData), for: .valueChanged)
        
        self.currentUser = self.delegate.currentUser
        
        clvRoom.delegate = self
        clvRoom.dataSource = self
        
        clvRoom.register(RoomCell.self, forCellWithReuseIdentifier: "RoomCell")
        clvRoom.register(UINib(nibName: "RoomCell", bundle: nil), forCellWithReuseIdentifier: "RoomCell")
        handlerSocket()
    }
    
    func showProgress(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    func dismissProgress(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    // MARK: - Functions
    func initActions(){
        let actionButton = JJFloatingActionButton()
        
        actionButton.buttonColor = UIColor.flatGreen()
        actionButton.buttonImageColor = .white
        actionButton.buttonImageSize = CGSize(width: 30, height: 30)
        
        actionButton.itemSizeRatio = CGFloat(0.8)
        actionButton.configureDefaultItem { item in
            item.titlePosition = .left

            item.titleLabel.font = UIFont.init(name: "Montserrat-SemiBold", size: CGFloat(15))
            item.titleLabel.textColor = .white
            item.buttonColor = .white

            item.layer.shadowColor = UIColor.black.cgColor
            item.layer.shadowOffset = CGSize(width: 0, height: 1)
            item.layer.shadowOpacity = Float(0.4)
            item.layer.shadowRadius = CGFloat(2)
        }
        
        let iconBackHome = UIImage(icon: .typIcons(.home), size: CGSize(width: 30, height: 30), textColor: .red, backgroundColor: .clear)
        actionButton.addItem(title: "Back Home", image: iconBackHome.withRenderingMode(.alwaysTemplate)) { item in
          // do something
            self.navigationController?.popViewController(animated: true)
        }

        let iconCreateHome = UIImage(icon: .typIcons(.plus), size: CGSize(width: 30, height: 30), textColor: .blue, backgroundColor: .clear )
        actionButton.addItem(title: "Create Room", image: iconCreateHome.withRenderingMode(.alwaysTemplate)) { item in
            
            self.socket.emit("client-send-createRoom", [
                        "token" : self.currentUser.access_token,
                        "username" : self.currentUser.username,
                        "idroom" : "\(self.randIdRooms())"
                        ])
            //        socket.on("server-send-hack", callback: { (data, _) in
            //            let json = JSON(data)
            //            let dataJson = json[0]
            //            let msg = dataJson["msg"].stringValue
            //            print("=======MESSAGE-HACK=======>",msg)
            //        })
            //
            //        socket.on("server-send-gamer", callback: { (data, _) in
            //            let json = JSON(data)
            //            let dataJson = json[0]["data"]
            //            let gamer = dataJson["gamer"].intValue
            //
            //            print("====GAMER===============>", gamer)
            //
            //            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PlayVC) as! PlayVC
            //                vc.mode = "Online"
            //                vc.gamer = 1
            //            vc.turn = true
            //            self.navigationController?.pushViewController(vc, animated: true)
            //        })
                    
                    let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PlayVC) as! PlayVC
                        vc.mode = "Online"
                        vc.gamer = 1
                    vc.turn = true
                    self.navigationController?.pushViewController(vc, animated: true)
          // do something
        }

//        actionButton.addItem(title: "item 3", image: nil) { item in
//          // do something
//        }

//        view.addSubview(actionButton)
//        actionButton.translatesAutoresizingMaskIntoConstraints = false
//        actionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
//        actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true

        // last 4 lines can be replaced with
         actionButton.display(inViewController: self)
    }
    
    @objc private func updateData(){
//        updateRooms()
        print("REFRESH=================REFRESH")
        self.clvRoom.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func handlerSocket(){
        debugPrint("HANDLER SOCKET ===>")
        socket.on("server-send-arrRooms", callback: { (data, _) in
                    let dataJson = JSON(data)
                    let dataRoom = dataJson[0]["data"]
                    
                    let arrRooms = dataRoom["rooms"].arrayObject as? [String]
                    self.delegate.listRoom = arrRooms ?? [String]()
                    self.clvRoom.reloadData()
                })
        socket.on("server-send-enoughRoom", callback: { (data, _) in
            self.showMessage("Error", "Room is enough players", .error)
        })
    }
    
    func randIdRooms() -> Int{
        return Int.random(in: 100000 ..< 900000)
    }
    // MARK: - Actions
    
    @IBAction func onBtnCreateRoom(_ sender: UIButton){
        
        socket.emit("client-send-createRoom", [
            "token" : self.currentUser.access_token,
            "username" : self.currentUser.username,
            "idroom" : "\(randIdRooms())"
            ])
//        socket.on("server-send-hack", callback: { (data, _) in
//            let json = JSON(data)
//            let dataJson = json[0]
//            let msg = dataJson["msg"].stringValue
//            print("=======MESSAGE-HACK=======>",msg)
//        })
//
//        socket.on("server-send-gamer", callback: { (data, _) in
//            let json = JSON(data)
//            let dataJson = json[0]["data"]
//            let gamer = dataJson["gamer"].intValue
//
//            print("====GAMER===============>", gamer)
//
//            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PlayVC) as! PlayVC
//                vc.mode = "Online"
//                vc.gamer = 1
//            vc.turn = true
//            self.navigationController?.pushViewController(vc, animated: true)
//        })
        
        let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PlayVC) as! PlayVC
            vc.mode = "Online"
            vc.gamer = 1
        vc.turn = true
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

extension RoomVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate.listRoom.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomCell
        cell.setName("\(self.delegate.listRoom[indexPath.row])")
        cell.vContainer.setCornerRadius(10)
//        cell.vContainer.backgroundColor = UIColor.flatSand()
       return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomCell", for: indexPath) as! RoomCell
        let data = [
            "token" : self.currentUser.access_token,
            "username" : self.currentUser.username,
            "idroom" : "\(self.delegate.listRoom[indexPath.row])"
        ] as [String:Any]
        socket.emit("client-send-joinRoom", data)
        
        
        
        socket.on("server-send-gamer", callback: { (data, _) in
            let json = JSON(data)
            let dataJson = json[0]
            let gamer = dataJson["gamer"].intValue
            
            print("GAMER ===============>", gamer)
            
            
        })
        
        socket.on("server-send-matched", callback: { (data, _) in
            let json = JSON(data)
            let dataJson = json[0]
            
            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PlayVC) as! PlayVC
                vc.mode = "Online"
            vc.side1 = "O"
            vc.side2 = "X"
            vc.gamer = 2
            vc.turn = false
//            let matrix = [[Int]].init(repeating: [Int].init(repeating: 0, count: 10), count: 10)
//            vc.matrix = dataJson["matrix"].arrayObject as? [[Int]] ?? matrix
            self.navigationController?.pushViewController(vc, animated: true)
        })
    }
}

extension RoomVC: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize (width: self.clvRoom.frame.width/2 - 5, height: self.clvRoom.frame.height/4 - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

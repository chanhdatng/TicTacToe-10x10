//
//  HomeVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/12/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import ChameleonFramework
import Alamofire
import NVActivityIndicatorView

class HomeVC: UIViewController, NVActivityIndicatorViewable {
    
    @IBOutlet weak var btnQuickStart: UIButton!
    @IBOutlet weak var btnRoom: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    @IBOutlet weak var btnRanking: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    
    @IBOutlet weak var vQS: UIView!
    @IBOutlet weak var vCR: UIView!
    @IBOutlet weak var vH : UIView!
    @IBOutlet weak var vR : UIView!
    @IBOutlet weak var vE : UIView!
    
    @IBOutlet weak var vGradient: GradientView!
    
    @IBOutlet weak var imgLogo: UIImageView!
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    
    var notificationToken: NotificationToken?
    
    var currentUser = User()
    
    var username = ""
    
    let socket = SocketIOManager.shared.socket
    
    let activityData = ActivityData.init(size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE, message: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE, messageFont: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_FONT, messageSpacing: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_SPACING, type: .ballClipRotateMultiple, color: NVActivityIndicatorView.DEFAULT_COLOR, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        imgLogo.layer.cornerRadius = imgLogo.frame.width/3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initLayout()
        // Do any additional setup after loading the view.
        let realm = try! Realm()
        currentUser = realm.object(ofType: User.self, forPrimaryKey: self.username)!
        self.delegate.currentUser = currentUser
        handlerSocket()
        self.vH.isHidden = true
    }
    
    func showProgress(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    func dismissProgress(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    func handlerSocket(){
        
        self.socket?.on("server-send-arrUsers") { (data, _) in
            let json = JSON(data)
            let dataJson = json[0]["data"]
            let arrUsers = dataJson["users"].arrayObject as! [String]
            self.delegate.listOnlineUser = arrUsers
//            self.showMessage("Information", "Someone has just been online.\nWe have \(self.delegate.listOnlineUser.count) users online!", .info)
        }
        
        
        //        if (SocketIOManager.shared.checkConnected(self.socket!)) {
        //
        //            self.socket?.on("server-send-arrUsers") { (data, _) in
        //                let json = JSON(data)
        //                let dataJson = json[0]["data"]
        //                let arrUsers = dataJson["users"].arrayObject as! [String]
        //                self.delegate.listOnlineUser = arrUsers
        //                self.showMessage("Information", "We have \(self.delegate.listOnlineUser.count) users online!", .info)
        //            }
        //                } else {
        //                print("SOCKET IS NOT CONNECTED!!!!!!!")
        //                SocketIOManager.shared.reConnectSocket()
        //                }
    }
    
    // MARK : Actions
    @IBAction func onBtn(_ sender: UIButton){
        switch sender {
        case btnQuickStart:
            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.PickSideVC) as! PickSideVC
            vc.mode = "Offline"
            self.navigationController?.pushViewController(vc, animated: true)
        case btnRoom:
            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.RoomVC) as! RoomVC
            self.navigationController?.pushViewController(vc, animated: true)
        case btnRanking:
            getTop10Rank()
        case btnExit:
            exit(0)
        case btnHistory:
            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.BluetoothVC) as! BluetoothVC
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func getTop10Rank(){
        self.showProgress()
        Alamofire.request(APIRouter.ranking).responseString { (response) in
            switch response.result {
            case .success(let jsonString):
                let rankRes = RankingResponse(JSONString: jsonString)
                let status = rankRes?.status
                if (status!) {
                    let data = rankRes?.data
                    
                    var listUser = [User]()
                    for u in data!{
                        let user = User()
                        user.username = u.username!
                        user.fullname = u.fullname!
                        user.score = u.score!
                        
                        listUser.append(user)
                    }
                    listUser.sort(by: { $0.score > $1.score })
                    let top10 = listUser.prefix(10)
                    self.dismissProgress()
                    let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.RankingVC) as! RankingVC
                    vc.listPlayer = Array(top10)
                    debugPrint(vc.listPlayer)
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let msg = rankRes?.message
                    self.showMessage("Error",msg!, .error)
                    return
                }
                break
            case .failure(let err):
                debugPrint("ERROR: ", err.localizedDescription)
                break
            }
        }
    }
    
}

extension HomeVC{
    func initLayout(){
        vQS.defaultShadow()
        btnQuickStart.backgroundColor = .systemBlue
        btnQuickStart.setCornerRadius(vQS.frame.height/2)
        btnQuickStart.setTitleColor(UIColor.white, for: .normal)
        
        vCR.defaultShadow()
        btnRoom.backgroundColor = .white
        btnRoom.setCornerRadius(vCR.frame.height/2)
        btnRoom.boderWith(UIColor.lightGray.cgColor , 0.1)
        btnRoom.setTitleColor(UIColor.systemBlue, for: .normal)
        
        vR.defaultShadow()
        btnRanking.backgroundColor = .systemBlue
        btnRanking.setCornerRadius(vR.frame.height/2)
        btnRanking.setTitleColor(UIColor.white, for: .normal)
        
        vH.defaultShadow()
        btnHistory.backgroundColor = .white
        btnHistory.setCornerRadius(vH.frame.height/2)
        btnHistory.boderWith(UIColor.lightGray.cgColor , 0.1)
        btnHistory.setTitleColor(UIColor.systemBlue, for: .normal)
        
        vE.defaultShadow()
        btnExit.backgroundColor = .red
        btnExit.setCornerRadius(vH.frame.height/2)
        btnExit.setTitleColor(UIColor.white, for: .normal)
        
    }
}

//
//  LoginVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/11/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
//import SVProgressHUD
import NVActivityIndicatorView

class LoginVC: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var imgLogo: UIImageView!
    
    @IBOutlet weak var txfUsername: Textfield!
    @IBOutlet weak var txfPassword: Textfield!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var btnForgot: UIButton!
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    let socket = SocketIOManager.shared.socket
    let activityData = ActivityData.init(size: NVActivityIndicatorView.DEFAULT_BLOCKER_SIZE, message: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE, messageFont: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_FONT, messageSpacing: NVActivityIndicatorView.DEFAULT_BLOCKER_MESSAGE_SPACING, type: .ballClipRotateMultiple, color: NVActivityIndicatorView.DEFAULT_COLOR, padding: NVActivityIndicatorView.DEFAULT_PADDING, displayTimeThreshold: NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD, minimumDisplayTime: NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME, backgroundColor: NVActivityIndicatorView.DEFAULT_BLOCKER_BACKGROUND_COLOR, textColor: NVActivityIndicatorView.DEFAULT_TEXT_COLOR)
    
    override func viewDidLayoutSubviews() {
        imgLogo.layer.cornerRadius = imgLogo.frame.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        self.txfUsername.delegate = self
        self.txfPassword.delegate = self
        initLayout()
//        SVProgressHUD.setContainerView(self.view)
        // Do any additional setup after loading the view.
    }
    
    func showProgress(){
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }
    
    func dismissProgress(){
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    func initLayout(){
        
        self.txfUsername.backgroundColor = UIColor.white
        self.txfPassword.backgroundColor = UIColor.white
        
        txfUsername.textColor = UIColor.gray
        txfPassword.textColor = UIColor.gray
        txfPassword.isSecureTextEntry = true
        
        
        imgLogo.layer.borderColor = UIColor.white.cgColor
        imgLogo.layer.borderWidth = CGFloat(1)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.autocorrectionType = .no
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Actions
    @IBAction func onBtnLogin(_ sender: UIButton){
        let username = self.txfUsername.text?.trim()
        let password = self.txfPassword.text?.trim()
//        socket.connect()
//        SVProgressHUD.show()
//        self.view.isUserInteractionEnabled = false
        showProgress()
        MGConnection.request(APIRouter.login(username: username ?? "", password: password ?? ""), LoginResponse.self) { (result, err) in
            guard err == nil else {
                print("False with Type: \(String(describing: err?.mErrorType)) and Message: \(String(describing: err?.mErrorMessage))")
                self.showMessage("Error", err!.mErrorMessage, .error)
//                SVProgressHUD.dismiss()
                self.dismissProgress()
                self.view.isUserInteractionEnabled = true
                return
            }
            
            let user = User()
            user.username = result!.username!
            user.fullname = result!.fullname!
            user.score = result!.score!
            user.access_token = result!.access_token!
            // SAVE DB REALM
            let realm = try! Realm()
            try! realm.write{
                realm.add(user,update: .modified)
            }
            self.delegate.currentUser = user
            
            SocketIOManager.shared.connectSocket()
            
            self.socket?.on("connect", callback: {_,_ in 
                self.socket?.emit("authenticate", [
                    "token" : user.access_token,
                    "username": user.username
                ])
            })
            
            
            self.dismissProgress()
//            SVProgressHUD.dismiss()
            let vc = Utilities.share.createVCwith(StaticData.nameStoryboard.nameSB, StaticData.nameVC.HomeVC) as! HomeVC
            vc.username = result!.username!
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

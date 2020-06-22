//
//  SignUpVC.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 5/29/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import SwiftMessages
import Alamofire
import ObjectMapper

class SignUpVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txfUsername: Textfield!
    @IBOutlet weak var txfPassword: Textfield!
    @IBOutlet weak var txfConfirmPassword: Textfield!
    @IBOutlet weak var txfEmail: Textfield!
    @IBOutlet weak var txfFullname: Textfield!
    
    @IBOutlet weak var imgLogo: UIImageView!

    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnForgot: UIButton!

    override func viewDidLayoutSubviews() {
        imgLogo.layer.cornerRadius = imgLogo.frame.height/2
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.txfUsername.delegate = self
        self.txfPassword.delegate = self
        self.txfEmail.delegate = self
        self.txfFullname.delegate = self
        self.txfConfirmPassword.delegate = self
        
        initLayout()
    }
    
    func initLayout(){
        
        self.txfUsername.backgroundColor = UIColor.white
        self.txfPassword.backgroundColor = UIColor.white
        self.txfConfirmPassword.backgroundColor = UIColor.white
        self.txfEmail.backgroundColor = UIColor.white
        self.txfFullname.backgroundColor = UIColor.white
        
        txfUsername.textColor = UIColor.gray
        txfPassword.textColor = UIColor.gray
        txfConfirmPassword.textColor = UIColor.gray
        txfEmail.textColor = UIColor.gray
        txfFullname.textColor = UIColor.gray
        
        txfPassword.isSecureTextEntry = true
        txfConfirmPassword.isSecureTextEntry = true
        
        imgLogo.layer.borderWidth = CGFloat(1)
        imgLogo.layer.borderColor = UIColor.white.cgColor
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.autocorrectionType = .no
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    
    @IBAction func pressedRegister(_ sender : UIButton){
        let fullname = txfFullname.text
        let username = txfUsername.text
        let email = txfEmail.text
        let pwd = txfPassword.text
        let confirmPwd = txfConfirmPassword.text
        
        if fullname!.isEmpty{
            showMessage("Error","Please fill fullname!", .error)
            txfFullname.shake()
            return
        } else if username!.isEmpty {
            showMessage("Error","Please fill username!", .error)
            txfUsername.shake()
            return
        } else if email!.isEmpty {
            showMessage("Error","Please fill email!", .error)
            txfEmail.shake()
            return
        } else if pwd!.isEmpty {
            showMessage("Error","Please fill password!", .error)
            txfPassword.shake()
            return
        } else if confirmPwd!.isEmpty {
            showMessage("Error","Please fill confirm password!", .error)
            txfConfirmPassword.shake()
            return
        }
        
        if pwd != confirmPwd {
            showMessage("Error","Passwords do not match!", .error)
            txfPassword.shake()
            txfConfirmPassword.shake()
            return
        }
        
        Alamofire.request(APIRouter.signup(Username: username!, Password: pwd!, Email: email!, Fullname: fullname!)).responseString { (response) in
            switch response.result {
            case .success(let jsonString):
                let registerRes = RegisterResponse(JSONString: jsonString)
                let error = registerRes?.error
                let msg = registerRes?.message
                
                if (error == false) {
                    self.showMessage("Success",msg!,.success)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showMessage("Error",msg!, .error)
                }
                break
            case .failure(let err):
                debugPrint("ERROR: ", err.localizedDescription)
                break
        }
        }
        
        
    }
    
    @IBAction func pressedLogin(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressedForgotPassword(_ sender: UIButton){
        
    }
}

extension UIViewController {
    func showMessage(_ title: String,_ message: String, _ theme: Theme){
        let view = MessageView.viewFromNib(layout: .cardView)
        view.button?.isHidden = true
        // Theme message elements with the warning style.
        view.configureTheme(theme)

        // Add a drop shadow.
        view.configureDropShadow()

        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        let iconText = ["🤔", "😳", "🙄", "😶"].randomElement()!
        view.configureContent(title: title, body: message, iconText: iconText)

        // Increase the external margin around the card. In general, the effect of this setting
        // depends on how the given layout is constrained to the layout margins.
        view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        // Reduce the corner radius (applicable to layouts featuring rounded corners).
        (view.backgroundView as? CornerRoundingView)?.cornerRadius = 10

        // Show the message.
        SwiftMessages.show(view: view)
    }
}

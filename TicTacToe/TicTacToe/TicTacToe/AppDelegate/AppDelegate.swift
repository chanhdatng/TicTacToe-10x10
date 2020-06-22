//
//  AppDelegate.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/9/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
//import SVProgressHUD

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var listOnlineUser = [String]()
    var listRoom = [String]()
    var currentUser = User()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
//        if #available(iOS 13.0, *){
//            
//        } else {
//            self.window = UIWindow(frame: UIScreen.main.bounds)
//            
//            SocketIOManager.shared.connectSocket()
//            
//            IQKeyboardManager.shared.enable = true
//            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
//            let navigateController = UINavigationController.init(rootViewController: initialViewController)
//            navigateController.setNavigationBarHidden(false, animated: false)
//            self.window?.rootViewController = navigateController
//            self.window?.makeKeyAndVisible()
//        }
        
//        SocketIOManager.shared.connectSocket()
//        SVProgressHUD.setDefaultMaskType(.black)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}


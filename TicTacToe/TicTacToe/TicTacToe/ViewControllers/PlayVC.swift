//
//  ViewController.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/9/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import SwiftIcons
import SocketIO
import SwiftyJSON
import PopMenu
import PopupDialog

class PlayVC: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate {
    
    var side1 = "" // your SIDE
    var side2 = "" // enemy SIDE
    var mode = "Online"
    var currentPlayer = 1
    var username = ""
    var turn = true
    
    //    var mark = 1
    var resultGame = -1
    var gamer = 0
    var x = 0
    var y = 0
    var matrix = [[Int]].init(repeating: [Int].init(repeating: 0, count: 10), count: 10)
    var matrixOffline = [[Int]].init(repeating: [Int].init(repeating: 0, count: 10), count: 10)
    
    var delegate = UIApplication.shared.delegate as! AppDelegate
    var socket = SocketIOManager.shared.socket!
    var currentUser = User()
    
    @IBOutlet weak var clvBoard: UICollectionView!
    @IBOutlet weak var bPlayerOn1: BasePlayerOnline!
    @IBOutlet weak var bPlayerOn2: BasePlayerOnline!
    
    @IBOutlet weak var vBtn: UIView!
    @IBOutlet weak var btnButton : UIButton!
    @IBOutlet weak var btnMask: UIButton!
    
    @IBOutlet weak var bPlayer1: BasePlayer!
    @IBOutlet weak var bPlayer2: BasePlayer!
    
    //    var sideButtonsView : RHSideButtons?
    //    var buttonsArr = [RHButtonView]()
    
    override func viewWillAppear(_ animated: Bool) {
        //        sideButtonsView!.reloadButtons()
        if mode == "Online"{
            bPlayer1.isHidden = true
            bPlayer2.isHidden = true
        } else if mode == "Offline"{
            bPlayerOn1.isHidden = true
            bPlayerOn2.isHidden = true
        }
        
        if gamer == 2 || mode == "Offline" {
            self.btnMask.isEnabled = false
            self.btnMask.isHidden = true
        }
        
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initLayout()
        
        currentUser = self.delegate.currentUser
        bPlayerOn1.lbPlayer.text = currentUser.username
        bPlayerOn1.imgPlayer.image = UIImage(named: "\(Int.random(in: 1...40))")
        bPlayerOn1.lbScore.text = "\(currentUser.score)"
        
        clvBoard.delegate = self
        clvBoard.dataSource = self
        clvBoard.register(XOCell.self, forCellWithReuseIdentifier: "XOCell")
        clvBoard.register(UINib.init(nibName: "XOCell", bundle: nil), forCellWithReuseIdentifier: "XOCell")
        
        socketHandlers()
    }
    
    func popupEndgame(_ title: String, _ message: String, _ img: String){
        // Prepare the popup assets
        let title = title
        let message = message
        let image = UIImage(named: img)
        
        let buttonAction = DefaultButton(title: "OK", dismissOnTap: false) {
            self.navigationController?.dismiss(animated: true, completion: nil)
            if self.mode == "Offline" {
                self.popBack(toControllerType: HomeVC.self)
            }
            self.popBack(toControllerType: RoomVC.self)
        }
        // Create the dialog
        let popup = PopupDialog(title: title, message: message, image: image)
        
        popup.addButtons([buttonAction])
        self.present(popup, animated: true, completion: nil)
        
    }
    
    func socketHandlers(){
        socket.on("server-send-matched", callback: { (data, _) in
            let json = JSON(data)
            let jsonData = json["data"]
            let matrix = jsonData["matrix"].arrayObject as? [[Int]] ?? self.matrix
            print("MATRIX =======> ",matrix)
            self.btnMask.isEnabled = false
            self.btnMask.isHidden = true
            self.showMessage("Success", "Game Start!", .success)
        })
        
        socket.on("server-send-data", callback: { (data, _) in
            let json = JSON(data)
            let dataJson = json[0]
            print("SEND-DATA: ========>", dataJson)
            
            if (dataJson["loser"].stringValue.isEmpty){
                print("2 player in room!")
            } else {
                
                print("LOSER: ",dataJson["loser"].stringValue)
                print("USER CURRENT: ",self.currentUser)
                self.endGameOut(dataJson["loser"].stringValue)
            }
            
            self.username = dataJson["name"].stringValue
            print("MATRIX =============== MATRIX: ", self.matrix)
            self.resultGame = dataJson["game"].intValue
            print("GAMEEEEEEEEEEEEEEEEEEEEEEEEEEE : ",self.resultGame)
            
            if self.resultGame == 1 {
                self.endGame(dataJson["name"].stringValue)
                return
            } else if self.resultGame == 0 {
                self.endGame(dataJson["name"].stringValue)
                return
            } 
            
            let mark = dataJson["mark"].intValue
            if mark != self.gamer {
                self.turn = true
                self.matrix = dataJson["matrix"].arrayObject as? [[Int]] ?? self.matrix
                
                print("MATRIX =============== MATRIX: ", self.matrix)
                self.clvBoard.reloadItems(at: [IndexPath.init(row: dataJson["x"].intValue/1, section: dataJson["y"].intValue/1)])
            } else {
                return
                //                    self.clvBoard.reloadData()
            }
        })
        
        socket.on("server-send-checkExistMark", callback: { (data, _) in
            debugPrint("DA CO NGUOI DANH!!!")
        })
        
    }
    func endGame(_ gamer: String){
        print("==========WINNER========")
        socket.emit("client-send-closeRoom")
        if gamer == self.currentUser.username {
            //            self.btnMask.isHidden = false
            //            self.btnMask.isEnabled = true
            //            self.btnMask.setImage(UIImage(named: "X")!, for: .normal)
            self.socket.emit("client-send-score-win", [
                "token" : self.currentUser.access_token,
                "username": self.currentUser.username
            ])
            
            self.popupEndgame("CONGRATULATIONS!", "Winner Winner Chicken Dinner", "youwin")
            
        } else {
            //            self.btnMask.isEnabled = true
            //            self.btnMask.isHidden = false
            //            self.btnMask.setImage(UIImage(named: "youlose")!, for: .normal)
            
            self.popupEndgame("OOPS..!", "You lose the game :(", "youlose")
        }
    }
    
    func endGameOut(_ gamer: String){
        socket.emit("client-send-closeRoom")
        if gamer != self.currentUser.username {
            self.socket.emit("client-send-score-win", [
                "token" : self.currentUser.access_token,
                "username": self.currentUser.username
            ])
            
            self.popupEndgame("CONGRATULATIONS!", "Winner Winner Chicken Dinner", "youwin")
            
        } else {
            self.popupEndgame("OOPS..!", "You lose the game :(", "youlose")
        }
    }
    
    
    // MARK: - CollectionView Configs
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "XOCell", for: indexPath) as! XOCell
        
        if matrix[indexPath.section][indexPath.row] == 1 {
            print("DRAWWWWWWWWWWWWWW X:", indexPath)
            cell.changeImg(UIImage(named: "X")!)
            cell.cellState = 1
        } else if matrix[indexPath.section][indexPath.row] == 2 {
            print("DRAWWWWWWWWWWWWWW X:", indexPath)
            cell.changeImg(UIImage(named: "O")!)
            cell.cellState = 2
        } else {
            cell.layer.borderWidth = 0.3
            cell.backgroundColor = .clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! XOCell
        
        if self.mode == "Online" {
            if turn{
                if cell.cellState == 0  {
                    let data = [
                        "token": self.currentUser.access_token,
                        "username": self.currentUser.username,
                        "gamer" : self.gamer,
                        "matrix" : self.matrix,
                        "x" : indexPath.row,
                        "y" : indexPath.section,
                        "boxsize" : 1
                        ] as [String : Any]
                    socket.emit("client-send-play", data)
                    
                    
                    let cell = collectionView.cellForItem(at: indexPath) as! XOCell
                    if gamer == 1{
                        cell.changeImg(UIImage(named: "X")!)
                        cell.cellState = gamer
                    } else {
                        cell.changeImg(UIImage(named: "O")!)
                        cell.cellState = gamer
                    }
                    // ĐỔI TURN
                    turn = false
                    
                } else {
                    print("DA CO NGUOI DANH")
                    self.showMessage("Warning!", "It's marked!", .warning)
                }
            } else {
                print("CHUA TOI LUOT!")
                self.showMessage("Warning!", "It's not your turn!", .warning)
            }
            
        } else { // MODE OFFLINE
            
            let cell = collectionView.cellForItem(at: indexPath) as! XOCell
            let x = indexPath.row
            let y = indexPath.section
            if cell.cellState == 0 {
                cell.cellState = currentPlayer
                self.matrixOffline[x][y] = currentPlayer
                print("MATRIX OFFLINE ",matrixOffline)
                if checkResult(matrix: matrixOffline, x: x, y: y, mark: currentPlayer) == true {
                    debugPrint("END GAMEEEEEEEEE")
                    if currentPlayer == 1 {
                        popupEndgame("Congratulation!", "GAMER \(side1) WIN THIS MATCH!", "youwin")
                    } else {
                        popupEndgame("Congratulation!", "GAMER \(side2) WIN THIS MATCH!", "youwin")
                    }
                    
                }
                if currentPlayer == 1 {
                    cell.changeImg(UIImage(named: side1)!)
                    currentPlayer = 2
                    
                } else {
                    cell.changeImg(UIImage(named: side2)!)
                    currentPlayer = 1
                }
            }
        }
    }
    // MARK: Actions
    
    @IBAction func onBtn(_ sender: UIButton) {
        presentMenu()
    }
    
    @IBAction func onBtnMask(_ sender: UIButton){
//        print("GAME IS NOT READY!")
//        btnMask.backgroundColor = .gray
//        btnMask.setTitle("GAME IS NOT READY YET!", for: .normal)
        self.showMessage("Warning", "Game is not ready yet!", .warning)
    }
    
    func presentMenu(){
        let exitRoomAction = PopMenuDefaultAction(title: "Exit Room", image: UIImage(named: "icon_exit"), color: .white)
        exitRoomAction.imageRenderingMode = .alwaysOriginal
        let reqDraw = PopMenuDefaultAction(title: "Draw ?", image: UIImage(named: "icon_draw"), color: .white)
        reqDraw.imageRenderingMode = .alwaysOriginal
        
        let menuViewController = PopMenuViewController(actions: [
            reqDraw,
            exitRoomAction
        ])
        
        menuViewController.appearance.popMenuFont = UIFont(name: "Montserrat-SemiBold", size: 17)!
        menuViewController.appearance.popMenuBackgroundStyle = .dimmed(color: .black, opacity: 0.6)
        menuViewController.appearance.popMenuColor.backgroundColor = .gradient(fill: .systemPink,.systemOrange)
        
        menuViewController.appearance.popMenuActionHeight = 60
        menuViewController.appearance.popMenuItemSeparator = .fill()
        menuViewController.shouldEnablePanGesture = false
        
        menuViewController.delegate = self
        
        menuViewController.didDismiss = { selected in
            if !selected {
                print("BYE")
            }
        }
        
        present(menuViewController, animated: true, completion: nil)
    }
    
}

extension PlayVC{
    func initLayout(){
        //BOARD
        clvBoard.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .extraLight))
        btnButton.cirle()
        if self.mode == "Online" {
            setupOnline()
        } else {
            setupOffline()
        }
    }
    
    func setupOffline(){
        if side1 == "X" {
            bPlayer1.setNamePlayer("Player One")
            bPlayer1.setImgPlayer(UIImage(named: "X")!)
            bPlayer1.setNameColor(.systemRed)
            
            
            //        bPlayerY.setCornerRadius(25)
            bPlayer2.setNamePlayer("Player Two")
            bPlayer2.setImgPlayer(UIImage(named: "O")!)
            bPlayer2.setNameColor(.systemTeal)
            bPlayer2.rotate(180)
        } else {
            bPlayer1.setNamePlayer("Player One")
            bPlayer1.setImgPlayer(UIImage(named: "O")!)
            bPlayer1.setNameColor(.systemTeal)
            
            //        bPlayerY.setCornerRadius(25)
            bPlayer2.setNamePlayer("Player Two")
            bPlayer2.setImgPlayer(UIImage(named: "X")!)
            bPlayer2.setNameColor(.systemRed)
            bPlayer2.rotate(180)
        }
    }
    
    func setupOnline(){
        if side1 == "X" {
            bPlayerOn1.setNamePlayer("Player One")
            bPlayerOn1.setImgPlayer(UIImage(named: "X")!)
            bPlayerOn1.setNameColor(.systemRed)
            //        bPlayOnerY.setCornerRadius(25)
            bPlayerOn2.setNamePlayer("Player Two")
            bPlayerOn2.setImgPlayer(UIImage(named: "O")!)
            bPlayerOn2.setNameColor(.systemTeal)
        } else {
            bPlayerOn1.setNamePlayer("Player One")
            bPlayerOn1.setImgPlayer(UIImage(named: "O")!)
            bPlayerOn1.setNameColor(.systemTeal)
            //        bPlayOnerY.setCornerRadius(25)
            bPlayerOn2.setNamePlayer("Player Two")
            bPlayerOn2.setImgPlayer(UIImage(named: "X")!)
            bPlayerOn2.setNameColor(.systemRed)
        }
    }
}
//
//extension PlayVC: RHSideButtonsDelegate {
//    func sideButtons(_ sideButtons: RHSideButtons, didSelectButtonAtIndex index: Int) {
//        if index == 0 {
//            self.popBack(toControllerType: HomeVC.self)
//        }
//    }
//
//    func sideButtons(_ sideButtons: RHSideButtons, didTriggerButtonChangeStateTo state: RHButtonState) {
//        print("🍭 Trigger button")
//    }
//}
//
//extension PlayVC: RHSideButtonsDataSource{
//    func sideButtonsNumberOfButtons(_ sideButtons: RHSideButtons) -> Int {
//        return buttonsArr.count
//    }
//
//    func sideButtons(_ sideButtons: RHSideButtons, buttonAtIndex index: Int) -> RHButtonView {
//        return buttonsArr[index]
//    }
//}


extension PlayVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: clvBoard.frame.width/10, height: clvBoard.frame.width/10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension PlayVC : PopMenuViewControllerDelegate{
    
    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        switch index {
        case 0:
            print("DRAW")
        case 1:
            if (self.mode == "Online"){
               self.socket.emit("client-send-logout")
            } else {
                self.popBack(toControllerType: HomeVC.self)
            }
        default:
            break
        }
    }
    
}


extension PlayVC {
    func check_Horizontal(matrix: [[Int]], x: Int, y : Int, mark: Int) -> Bool {
        var count = 0
        //        var result = 0
        let start = max(0, x-4)
        let end = min(9,x+4)
        
        for i in start...end {
            if matrix[i][y] == mark {
                count+=1
            } else {
                count = 0
            }
            if count == 5 { return true}
        }
        
        return false
    }
    
    func check_Vertical(matrix: [[Int]], x: Int, y : Int, mark: Int) -> Bool {
        var count = 0;
        let start   = max(0, y - 4)
        let end     = min(9, y + 4);
        
        for i in start...end {
            if matrix[x][i] == mark {
                count+=1
            } else {
                count = 0
            }
            if count == 5 { return true}
        }
        return false;
    }
    
    func check_DiagonalMain(matrix: [[Int]], x: Int, y : Int, mark: Int) -> Bool {
        var count = 0;
        var start_x = x
        var start_y = y
        var end_x   = x
        var end_y   = y
        var k = 1;
        
        while (start_x != 0 && start_y != 0 && k < 5) {
            start_x -= 1
            start_y -= 1
            k += 1
        }
        k = 1
        while ((end_x < 9) && (end_y < 9) && k < 5) {
            end_x += 1
            end_y += 1
            k += 1
        }
        var j = start_y
        for i in start_x...end_x {
            
            if matrix[i][j] == mark {
                count += 1
            } else {
                count = 0
            }
            
            if count == 5 {return true}
            if j<9 {j += 1}
        }
        
        return false
    }
    
    func check_DiagonalSub(matrix: [[Int]], x: Int, y : Int, mark: Int) -> Bool {
        var count = 0;
        var start_x = x
        var start_y = y
        var end_x   = x
        var end_y   = y
        var k = 1;
        
        while ((start_x != 0) && (start_y < 9) && k < 5) {
            start_x -= 1
            start_y += 1
            k += 1
        }
        k = 1;
        while ((end_x < 9) && (end_y != 0) && k < 5) {
            end_x += 1
            end_y -= 1
            k += 1
        }
        var j = start_y
        for i in start_x...end_x {
            if matrix[i][j] == mark {
                count += 1
            } else {
                count = 0
            }
            
            if count == 5 {return true}
            
            if j>0 {j -= 1}
        }
        return false;
    }
    
    func checkResult(matrix: [[Int]], x: Int, y : Int, mark: Int) -> Bool {
        return self.check_Horizontal(matrix: matrix, x: x, y: y, mark: mark) || self.check_Vertical(matrix: matrix, x: x, y: y, mark: mark) || self.check_DiagonalSub(matrix: matrix, x: x, y: y, mark: mark) || self.check_DiagonalMain(matrix: matrix, x: x, y: y, mark: mark)
    }
}



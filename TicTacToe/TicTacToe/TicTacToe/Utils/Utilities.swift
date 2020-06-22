//
//  Utilities.swift
//  TicTacToe
//
//  Created by Nguyen Chanh Dat on 4/12/20.
//  Copyright © 2020 Nguyen Chanh Dat. All rights reserved.
//

import UIKit
import SocketIO
import SwiftyJSON

class Utilities: NSObject{
    static let share = Utilities()
    
    func createVCwith(_ nameSB: String, _ nameVC: String) -> UIViewController {
        return UIStoryboard.init(name: nameSB, bundle: nil).instantiateViewController(withIdentifier: nameVC)
    }

}

extension UIView{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    func cirle() {
        self.setCornerRadius(self.frame.size.height/2)
    }
    
    func boderWith(_ color: CGColor, _ width: CGFloat) {
        self.layer.borderColor = color
        self.layer.borderWidth = width
    }
    
    func setCornerRadius(_ corner: CGFloat) {
        self.layer.cornerRadius = corner
        self.clipsToBounds = true
    }
    
    // SHADOW Left andd Bottom
    func LeftAndBottomShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 8).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // SHADOW Around
    func aroundShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.backgroundColor = UIColor.clear.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
    }
    
    func defaultShadow(){
        self.aroundShadow(color: .lightGray, opacity: 0.2, offSet: CGSize(width: 0.1, height: 0.1), radius: 16, scale: false)
    }
    
    func noShadow() {
        self.aroundShadow(color: .clear, opacity: 0, offSet: CGSize(width: 0, height: 0), radius: 0, scale: false)
    }
    
    func rotate(_ angle: CGFloat) {
        let radians = angle / 180.0 * CGFloat.pi
        let rotation = self.transform.rotated(by: radians);
        self.transform = rotation
    }
}

extension UIViewController{
    func popBack<T: UIViewController>(toControllerType: T.Type) {
        if var viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers {
                if currentViewController .isKind(of: toControllerType) {
                    self.navigationController?.popToViewController(currentViewController, animated: true)
                    break
                }
            }
        }
    }
}

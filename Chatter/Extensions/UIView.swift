//
//  UIView.swift
//  Chatter
//
//  Created by Nader Said on 21/07/2022.
//

import UIKit

extension UIView
{
    func addGradientLayer()
    {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = CGSize(width: Constants.screenWidth, height: Constants.screenHeight)
        layer.frame.origin = CGPoint(x: 0 , y: 0)
        
        let color1 = UIColor(red:200.0/255, green:200.0/255, blue: 200.0/255, alpha:0.1).cgColor
        let color2 = UIColor(red:150.0/255, green:150.0/255, blue: 150.0/255, alpha:0.1).cgColor
        let color3 = UIColor(red:100.0/255, green:100.0/255, blue: 100.0/255, alpha:0.1).cgColor
        let color4 = UIColor(red:50.0/255, green:50.0/255, blue:50.0/255, alpha:0.1).cgColor
        let color5 = UIColor(red:0.0/255, green:0.0/255, blue:0.0/255, alpha:0.1).cgColor
        let color6 = UIColor(red:150.0/255, green:150.0/255, blue:150.0/255, alpha:0.1).cgColor

        layer.colors = [color1,color2,color3,color4,color5,color6]
        self.layer.insertSublayer(layer, at: 0)
    }
}

//
//  UIBarButtonItem.swift
//  Chatter
//
//  Created by nader said on 15/07/2022.
//

import UIKit

extension UIBarButtonItem
{
    
    func changeCustomBarBtnImage(img: UIImage?)
    {
        DispatchQueue.main.async
        {
            [weak self] in
            guard let self = self else { return }
            let btn = self.customView as! UIButton
            
            btn.setImage(img?.withRenderingMode(.alwaysOriginal), for: .normal)
            self.customView = btn
        }
       
    }
}

//
//  UITableViewCell.swift
//  Chatter
//
//  Created by nader said on 13/07/2022.
//

import UIKit

extension UITableViewCell
{
    static var reuseIdentfier : String
    {
        return String(describing: self)
    }

}

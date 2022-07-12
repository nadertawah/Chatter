//
//  UIViewController.swift
//  Chatter
//
//  Created by nader said on 12/07/2022.
//

import UIKit

extension UIViewController
{
    func showAlert(title: String,msg: String)
    {
        DispatchQueue.main.async
        {
            let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(action)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true)
        }
    }
}

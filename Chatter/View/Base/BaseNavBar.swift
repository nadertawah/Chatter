//
//  BaseNavBar.swift
//  Chatter
//
//  Created by nader said on 12/07/2022.
//

import UIKit

class BaseNavBar : UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.isNavigationBarHidden = false
        
        //NavBar Attributes
        //navigationBar.titleTextAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18)]
        navigationBar.prefersLargeTitles = true
        navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.chatterGreyColor]
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.chatterGreyColor]
        navigationBar.tintColor = UIColor.chatterGreyColor
        navigationBar.backgroundColor = UIColor.chatterGreenColor
    }
    
    
}


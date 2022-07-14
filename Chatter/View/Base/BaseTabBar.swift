//
//  BaseTabBar.swift
//  Chatter
//
//  Created by nader said on 12/07/2022.
//

import UIKit

class BaseTabBar:  UITabBarController
{
    var dataPersistant : DataPersistantProtocol!
    
    init(dataPersistant : DataPersistantProtocol)
    {
        self.dataPersistant = dataPersistant
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //initiate tabBar VC(s)
        
        //recent screen
        let recentVC = RecentView()
        
        //users Screen
        let usersVC = UsersView()
        
        //me screen
        let profileVC = ProfileView()
        
        
        let vc1 = BaseNavBar.init(rootViewController: recentVC)
        let vc2 = BaseNavBar.init(rootViewController: usersVC)
        let vc3 = BaseNavBar.init(rootViewController: profileVC)
        
        //set tabBar title(s)
        vc1.title = "Recent"
        vc2.title = "Find Friends"
        vc3.title = "Profile"
        
        
        //Set VC(s) in the tabBar
        self.setViewControllers([vc1, vc2, vc3], animated: true)
        
        //Set tabBar image
        guard let items = self.tabBar.items else { return }
        items[0].image = UIImage(systemName: "clock.fill")
        items[1].image = UIImage(systemName: "person.3.sequence.fill")
        items[2].image = UIImage(systemName: "person.fill")

       
        //TODO: - set default selected index
        
        //set tabBar attributes
        self.tabBar.tintColor = Constants.chatterGreenColor
        self.tabBar.backgroundColor = Constants.chatterGreyColor
        self.tabBar.unselectedItemTintColor = .white
        //set delegate
       // self.delegate = self
        
        //override dark mode
        self.overrideUserInterfaceStyle = .light
    }
    
}


//extension BaseTabBar : UITabBarControllerDelegate
//{
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
//    {
//        if viewController is
//        {
//        }
//    }
//}

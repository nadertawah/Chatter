//
//  ProfileView.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import UIKit
import RxSwift

class ProfileView: UIViewController
{
    
    //MARK: - IBOutlet(s)

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUI()
    }

    //MARK: - IBAction(s)
    @IBAction func logOutBtnPressed(_ sender: UIButton)
    {
        VM.logout
        {
            [weak self] in
            let loginV = LoginRegisterView()
            self?.navigationController?.isNavigationBarHidden = true
            self?.navigationController?.setViewControllers([loginV], animated: true)
            self?.tabBarController?.tabBar.isHidden = true
        }
    }
    
    //MARK: - Var(s)
    var VM = ProfileVM()
    let bag = DisposeBag()
    
    //MARK: - Helper Funcs
    func setUI()
    {
        title = "Profile"
        
        //bind to VM
        VM.user.subscribe
        {
            [weak self] user in
            DispatchQueue.main.async
            {
                guard let self = self, let user = user.element else {return}
                self.imgView.image = UIImage.imageFromString(imgSTR: (user.avatar) )?.circleMasked
                self.nameLabel.text = "Name: " + (user.fullName)
                self.emailLabel.text = "Email: " + (user.email)
                self.createdAtLabel.text = "Created at: " + (user.createdAt.localString())
            }
        }.disposed(by: bag)
    }
    
}

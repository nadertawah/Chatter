//
//  UsersView.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import UIKit
import RxSwift

class UsersView: UIViewController, UIScrollViewDelegate
{
    //MARK: - IBOutlet(s)
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setUI()
    }
    
    
    //MARK: - IBAction(s)
    
    
    //MARK: - Var(s)
    var VM = UsersVM()
    let bag = DisposeBag()
    
    //MARK: - Helper Funcs
    func setUI()
    {
        title = "Find Friends"
        
        //register cell
        tableView.register(UINib(nibName: UserCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: UserCell.reuseIdentfier)
        
        //bind vm
        VM.users.bind(to: tableView.rx.items(cellIdentifier: UserCell.reuseIdentfier, cellType: UserCell.self))
        {
            idx,user,cell in
            DispatchQueue.main.async
            {
                cell.nameLabel.text = user.fullName
                cell.emailLabel.text = user.email
                cell.imgView.image = UIImage.imageFromString(imgSTR: user.avatar)?.circleMasked
            }
            
        }.disposed(by: bag)
        
        //set tableView delegate
        tableView.rx.setDelegate(self).disposed(by: bag)
        
        //set did select row at
        tableView.rx.itemSelected.subscribe(onNext:
        {
            [weak self] indexPath in
            DispatchQueue.main.async
            {
                guard let self = self else {return}
                let user = self.VM.users.value[indexPath.row]
                
                let chatVC = ChatView(chatWith: user)
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
            
        }).disposed(by: bag)
        
    }
}


extension UsersView : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        100
    }
}

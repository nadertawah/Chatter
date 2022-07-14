//
//  RecentView.swift
//  Chatter
//
//  Created by Nader Said on 12/07/2022.
//

import UIKit
import RxCocoa
import RxSwift

class RecentView: UIViewController, UIScrollViewDelegate
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
    let VM = RecentVM()
    let bag = DisposeBag()
    
    //MARK: - Helper Funcs
    func setUI()
    {
        title = "Recent Chats"
        
        // Register cells
        tableView.register(UINib(nibName: RecentViewCell.reuseIdentfier, bundle: nil), forCellReuseIdentifier: RecentViewCell.reuseIdentfier)
        
        //set tableView delegate
        tableView.rx.setDelegate(self).disposed(by: bag)
        
        //bind VM
        VM.recentChats.bind(to: tableView.rx.items(cellIdentifier: RecentViewCell.reuseIdentfier, cellType: RecentViewCell.self))
        {
            [weak self] idx,item,cell in
            guard let self = self else
            {return}
            
            cell.lastMessageLBL.text = item.lastMessage.message
            if item.lastMessage.type == .image
            {
                cell.lastMessageLBL.text = "[Image]"
            }
            cell.nameLBL.text = item.friend.fullName
            let img = UIImage.imageFromString(imgSTR: item.friend.avatar)?.circleMasked
            cell.avatar.image = img

            cell.timeStampLBL.text = item.lastMessage.date.chatterTimeStamp()
            
            if item.unreadCount != nil , item.unreadCount! > 0
            {
                cell.accessoryView = self.setBadge(count: item.unreadCount!)
                cell.contentView.superview?.backgroundColor = Constants.chatterGreyColor
            }
            else
            {
                cell.accessoryView = nil
            }
        }.disposed(by: bag)
        
        
        //set did select row at
        tableView.rx.itemSelected.subscribe(onNext:
                                                                {
            [weak self] indexPath in
            guard let self = self else {return}
            self.VM.readMessages(index: indexPath.row)
            let user = self.VM.recentChats.value[indexPath.row].friend
            
            let chatVC = BaseNavBar.init(rootViewController: ChatView(chatWith: user))
            chatVC.modalPresentationStyle = .fullScreen
            self.present(chatVC, animated: true)
        }).disposed(by: bag)
    }
    
    func setBadge(count: Int) -> UILabel
    {
        let width: CGFloat = 26
        let badge = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
        badge.text = "\(count)"
        badge.layer.cornerRadius = width / 2
        badge.layer.masksToBounds = true
        badge.textAlignment = .center
        badge.textColor = Constants.chatterGreyColor
        badge.backgroundColor = .green
        return badge
    }
}


extension RecentView : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100
    }
}

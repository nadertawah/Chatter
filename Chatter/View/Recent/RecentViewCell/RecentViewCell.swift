//
//  RecentViewCell.swift
//  Chatter
//
//  Created by nader said on 12/07/2022.
//

import UIKit

class RecentViewCell: UITableViewCell
{
    //MARK: - IBOutlet(s)
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var nameLBL: UILabel!
    
    @IBOutlet weak var lastMessageLBL: UILabel!
    
    @IBOutlet weak var timeStampLBL: UILabel!
    
    @IBOutlet weak var backView : UIView!
    {
        didSet
        {
            backView.layer.cornerRadius = 7
            backView.layer.shadowColor = UIColor.black.cgColor
            backView.layer.shadowOffset = CGSize(width: 1, height: 5)
            backView.layer.shadowRadius = 7
            backView.layer.shadowOpacity = 0.7
        }
    }
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    

}

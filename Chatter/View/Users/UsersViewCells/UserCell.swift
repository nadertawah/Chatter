//
//  UserCell.swift
//  Chatter
//
//  Created by nader said on 14/07/2022.
//

import UIKit

class UserCell: UITableViewCell
{
    //MARK: - IBOutlet(s)

    @IBOutlet weak var backView: UIView!
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
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
}

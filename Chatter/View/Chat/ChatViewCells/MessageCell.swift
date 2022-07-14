//
//  MessageCell.swift
//  Chatter
//
//  Created by nader said on 14/07/2022.
//

import UIKit

class MessageCell: UITableViewCell
{

    //MARK: - IBOutlet(s)
    
    @IBOutlet weak var msgLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    @IBOutlet weak var trailingBackView: NSLayoutConstraint!
    
    @IBOutlet weak var leadingBackView: NSLayoutConstraint!
    
    @IBOutlet weak var backView: UIView!
    {
        didSet
        {
            backView.layer.cornerRadius = 10
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

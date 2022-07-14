//
//  ImgMessageCell.swift
//  Chatter
//
//  Created by nader said on 14/07/2022.
//

import UIKit

class ImgMessageCell: UITableViewCell
{

    //MARK: - IBOutlet(s)
    
    @IBOutlet weak var backView: UIView!
    {
        didSet
        {
            backView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var trailingBackView: NSLayoutConstraint!
    @IBOutlet weak var leadingBackView: NSLayoutConstraint!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

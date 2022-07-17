//
//  OnlineStatusView.swift
//  Chatter
//
//  Created by nader said on 17/07/2022.
//

import UIKit

class OnlineStatusView: UIView
{
    private let nameLabel = UILabel()
    let onlineLabel = UILabel()
    
    override init (frame : CGRect)
    {
        super.init(frame : frame)
        
        nameLabel.text = "Name"
        
        onlineLabel.attributedText = NSAttributedString(string: "Online", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.chatterGreyColor])
        
        addSubview(nameLabel)
        addSubview(onlineLabel)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews()
    {
        super.layoutSubviews()

        nameLabel.frame.size = CGSize(width: frame.width , height: frame.height / 2)
        
        onlineLabel.frame.size = CGSize(width: frame.width , height: frame.height / 2)
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        onlineLabel.translatesAutoresizingMaskIntoConstraints = false

        let nameLeadingConstraint = NSLayoutConstraint(item: nameLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        
        let nameTrailingConstraint = NSLayoutConstraint(item: nameLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0)
        
        let nametTopConstraint = NSLayoutConstraint(item: nameLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 8)
        
        let onlineLeadingConstraint = NSLayoutConstraint(item: onlineLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0)
        
        let onlineTopConstraint = NSLayoutConstraint(item: onlineLabel, attribute: .top, relatedBy: .equal, toItem: nameLabel, attribute: .bottom, multiplier: 1, constant: -3)
        
        self.removeConstraints([nameLeadingConstraint,nameTrailingConstraint,nametTopConstraint,onlineLeadingConstraint,onlineTopConstraint])
        self.addConstraints([nameLeadingConstraint,nameTrailingConstraint,nametTopConstraint,onlineLeadingConstraint,onlineTopConstraint])
    }
    
    func setName(_ name :String)
    {
        nameLabel.attributedText = NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),NSAttributedString.Key.foregroundColor : UIColor.chatterGreyColor])
    }
    
}

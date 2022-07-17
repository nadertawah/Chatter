//
//  VoiceNoteMessageCell.swift
//  Chatter
//
//  Created by nader said on 16/07/2022.
//

import UIKit

class VoiceNoteMessageCell: UITableViewCell
{
    //MARK: - IBOutlet(s)

    @IBOutlet weak var backView: UIView!
    {
        didSet
        {
            backView.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBOutlet weak var backViewTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backViewLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
}

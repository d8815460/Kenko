//
//  TimeLineCustomCell.swift
//  Kenko
//
//  Created by 駿逸 陳 on 2016/8/10.
//  Copyright © 2016年 駿逸 陳. All rights reserved.
//

import UIKit
import ParseUI


class TimeLineCustomCell: PFTableViewCell {
    @IBOutlet var typeImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var dateImageView: UIImageView!
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var postLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        dateImageView.image = UIImage(named: "clock")
        dateImageView.alpha = 0.20
        profileImageView.layer.cornerRadius = 30
        
        nameLabel.font = UIFont(name: MegaTheme.fontName, size: 16)
        nameLabel.textColor = MegaTheme.darkColor
        
        postLabel?.font = UIFont(name: MegaTheme.fontName, size: 14)
        postLabel?.textColor = MegaTheme.lightColor
        
        dateLabel.font = UIFont(name: MegaTheme.fontName, size: 14)
        dateLabel.textColor = MegaTheme.lightColor
        
        photoImageView?.layer.borderWidth = 0.4
        photoImageView?.layer.borderColor = UIColor(white: 0.92, alpha: 1.0).CGColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if postLabel != nil {
            let label = postLabel!
            label.preferredMaxLayoutWidth = CGRectGetWidth(label.frame)
        }
    }
}

//
//  FriendsCell.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 31/12/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit

class FriendsCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labelTxt: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.clipsToBounds = true
        self.imgView.layer.cornerRadius = self.imgView.frame.size.width / 2
        self.imgView.layer.borderWidth = 1
        self.imgView.layer.borderColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}

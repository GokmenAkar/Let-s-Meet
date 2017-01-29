//
//  Cell.swift
//  FindYourFriendDemo
//
//  Created by Gokmen on 07/12/2016.
//  Copyright © 2016 Akar. All rights reserved.
//

import UIKit
import Firebase

class Cell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var labelTxt: UILabel!
    @IBOutlet weak var buttonImg: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imgView.clipsToBounds = true
        self.imgView.layer.cornerRadius = self.imgView.frame.size.width / 2
        self.imgView.layer.borderWidth = 1
        self.imgView.layer.borderColor = UIColor.init(red: 21/255, green: 79/255, blue: 114/255, alpha: 1.0).cgColor
        
        self.buttonImg.layer.cornerRadius = 12
        self.buttonImg.clipsToBounds = true

    }
    
    func buttonAlpha() {
        UIView.animate(withDuration: 1.0) {
            self.buttonImg.alpha = 1.0
        }
    }
    
    var buttonFunc: (() -> (Void))!
    
    func setFunction(_ function: @escaping () -> Void) {
        self.buttonFunc = function
    }
    
    @IBAction func requestBtn(_ sender: UIButton) {
        
        print("Gonderme butonuna basildi")

        var timer = Timer()
        buttonImg.alpha = 0.7
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
            self.buttonAlpha()
        })
        
        // // // // // //
        buttonFunc()
    }
}

//
//  InviteTableViewCell.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 15/05/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class InviteTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var inviteButton: UIButton!
    
    var user: User? {
        
        didSet {
        
            updateView()
        
        }
        
    }
    
    func updateView() {
        
        nameLabel.text = user?.username
        
        if let photoUrlString = user?.profileImageUrl {
            
            let photoUrl = URL(string: photoUrlString)
            
            profileImage.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImage"))
            
        }

        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

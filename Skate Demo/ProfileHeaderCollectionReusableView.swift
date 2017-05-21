//
//  ProfileHeaderCollectionReusableView.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 20/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit


protocol ProfileHeaderCollectionReusableViewDelegate {
    func updateFollowButton(forUser user: User)
}

protocol ProfileHeaderCollectionReusableViewDelegateSwitchSettingVC {
    func goToSettingVC()
}


class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var userPostCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCounterLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    
   
    
    
    var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    var delegate2: ProfileHeaderCollectionReusableViewDelegateSwitchSettingVC?
    
    var user: User? {
        
        didSet {
            updateView()
        }
        
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        clear()
        
    }
    
    
    
    
    
    func updateView() {
            
            self.nameLabel.text = user!.username
            
            if let photoUrlString = user!.profileImageUrl {
                
            let photoUrl = URL(string: photoUrlString)
                
            self.profileImage.sd_setImage(with: photoUrl)
                
            }
        
         //Updating how many posts user has
        
        
        Api.userPosts.getCountUserPosts(userId: user!.id!) { (count) in
            
            self.userPostCountLabel.text = "\(count)"
            
        }
        
        Api.Follow.getFollowingCount(userId: user!.id!) { (count) in
            
            self.followingCountLabel.text = "\(count)"
            
        }
        
        Api.Follow.getFollowerCount(userId: user!.id!) { (count) in
            
            self.followerCounterLabel.text = "\(count)"
            
        }
        
        
        //Checking is user is current user
        
        if user?.id == Api.User.CURRENT_USER?.uid {
            
            followButton.setTitle("Edit", for: UIControlState.normal)
            
            //Segue to setting VC
            
            followButton.addTarget(self, action: #selector(self.goToSettingVC), for: UIControlEvents.touchUpInside)

            
        } else {
            
            //If user is not current edit become follow button
            
            updateStateFollowButton()
            
        }
        
    }
    
    
    func clear() {
        
        self.nameLabel.text = ""
        self.userPostCountLabel.text = ""
        self.followingCountLabel.text = ""
        self.followerCounterLabel.text = ""
        
    }
    
    
    
    func goToSettingVC() {
        
        delegate2?.goToSettingVC()
        
    }
    
    func updateStateFollowButton() {
        
        if user!.isFollowing! {
            
            configureUnFollowButton()
            
        } else {
            
            configureFollowButton()
            
        }
        
    }
    
    func configureFollowButton() {
        
        //UI Button
        
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 69/255, green: 142/255, blue: 255/255, alpha: 1)
        
        followButton.setTitle("Follow", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.followAction), for: UIControlEvents.touchUpInside)
        
        
    }
    
    func configureUnFollowButton() {
        
        //UI Button
        
        followButton.layer.borderWidth = 1
        followButton.layer.borderColor = UIColor(red: 226/255, green: 228/255, blue: 232.255, alpha: 1).cgColor
        followButton.layer.cornerRadius = 5
        followButton.clipsToBounds = true
        followButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followButton.backgroundColor = UIColor(red: 66/255, green: 244/255, blue: 75/255, alpha: 1)
        
        followButton.setTitle("Following", for: UIControlState.normal)
        followButton.addTarget(self, action: #selector(self.unfollowAction), for: UIControlEvents.touchUpInside)
        
    }
    
    
    //followAction and unfollowAction within FollowApi
    
    func followAction() {
        
        
        if user!.isFollowing! == false {
            
            Api.Follow.followAction(withUser: user!.id!)
            configureUnFollowButton()
            
            user!.isFollowing! = true
            
            //Setting a delegate so any other view can find out about changes to follow state in profile
            
            delegate?.updateFollowButton(forUser: user!)
            
        }
        
        
    }
    
    func unfollowAction() {
        
        if user!.isFollowing! == true {
            
            Api.Follow.unfollowAction(withUser: user!.id!)
            configureFollowButton()
            
            user!.isFollowing! = false
            
            delegate?.updateFollowButton(forUser: user!)

            
        }
    }

    
}

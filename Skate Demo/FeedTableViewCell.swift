//
//  FeedTableViewCell.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 06/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import ProgressHUD
import AVFoundation
import KILabel

//Declaring delegate protocol

protocol FeedTableViewCellDelegate {
    func goToCommentVC(postId: String)
    func goToProfileUserVC(userId: String)
    func goToHashtag(tag: String)
}

class FeedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var dislikeImageView: UIImageView!
    @IBOutlet weak var commentView: UIImageView!
    @IBOutlet weak var shareView: UIImageView!
    @IBOutlet weak var likeCountButton: UIButton!
    @IBOutlet weak var captionLabel: KILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    //DelegateCell = if reuse cell somewhere else dont need a switch implementation
    
    var delegate: FeedTableViewCellDelegate?
    
    var player: AVPlayer?
    
    var playerLayer: AVPlayerLayer?
    
    var post: Post? {
        didSet {
            
            updateViewPost()
            
        }
    }
    
    var user: User? {
        didSet {
            
            setUserInfo()
            
        }
    }
    
    var isMuted = true
    
    func updateViewPost() {
        
        //Hashtag within Post
        
        captionLabel.text = post?.caption
        
        captionLabel.hashtagLinkTapHandler = { label, string, range in
        
            let tag = String(string.characters.dropFirst())
            
            self.delegate?.goToHashtag(tag: tag)
        
        }
        
        //Captions within posts
        
        captionLabel.userHandleLinkTapHandler =  { label, string, range in

        let mention = String(string.characters.dropFirst())
            
        Api.User.observeUserByUsername(username: mention.lowercased(), completion: { (user) in
            
            self.delegate?.goToProfileUserVC(userId: user.id!)
        
            
        })
            
            
    }
    
        
        if let ratio = post?.ratio {
            
            print("frame post Image: \(postImageView.frame)")
            
            heightConstraint.constant = UIScreen.main.bounds.width / ratio
            
            layoutIfNeeded()
            
            print("frame post Image: \(postImageView.frame)")
            
        }
        
        //Getting photo url from database
        
        if let photoUrlString = post?.photoUrl {
            
            let photoUrl = URL(string: photoUrlString)
            postImageView.sd_setImage(with: photoUrl)
            
        }
        
        if let videoUrlString = post?.videoUrl, let videoUrl = URL(string: videoUrlString) {
            
            print("videoUrlString: \(videoUrlString)")
            
            //How video is played and framed
            
            self.volumeView.isHidden = false
            
            player = AVPlayer(url: videoUrl)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = postImageView.frame
            playerLayer?.frame.size.width = UIScreen.main.bounds.width
            
            self.contentView.layer.addSublayer(playerLayer!)
            
            self.volumeView.layer.zPosition = 1
            
            player?.play()
            
            player?.isMuted = isMuted
            
        }
        
        //Timestamp for post
        
        if let timestamp = post?.timestamp {
            
            print(timestamp)
            
            let timestampDate = Date(timeIntervalSince1970: Double(timestamp))
            
            let now = Date()
            
            let components = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfMonth])
            
            let diff = Calendar.current.dateComponents(components, from: timestampDate, to: now)
            
        
            var timeText = ""
            
            if diff.second! <= 0 {
                
                timeText = "Now"
                
            }
            
            if diff.second! > 0 && diff.minute! == 0 {
                
                timeText = (diff.second == 1) ? "\(diff.second!) second ago" :  "\(diff.second!) seconds ago"
            }
            
            if diff.minute! > 0 && diff.hour! == 0 {
                
                timeText = (diff.minute == 1) ? "\(diff.minute!) minute ago" :  "\(diff.minute!) minutes ago"
                
            }
            
            if diff.hour! > 0 && diff.day! == 0 {
                
                timeText = (diff.hour == 1) ? "\(diff.hour!) hour ago" :  "\(diff.hour!) hours ago"
                
            }

            if diff.day! > 0 && diff.weekOfMonth! == 0 {
                
                timeText = (diff.day == 1) ? "\(diff.day!) day ago" :  "\(diff.hour!) days ago"
                
            }
            
            if diff.weekOfMonth! > 0 {
                
                timeText = (diff.weekOfMonth == 1) ? "\(diff.weekOfMonth!) weeks ago" :  "\(diff.weekOfMonth!) weeks ago"
                
            }
            
           
            
            timeLabel.text = timeText
            
            }
        

        //Observing the like button being changed and updating from other users
        
        self.updateLike(post: self.post!)
        
        
    }
    
    @IBAction func volumeButton_TouchUpInside(_ sender: UIButton) {
    
        if isMuted {
            
            //If is muted true flip to false
            
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "AudioWave"), for: UIControlState.normal)
            
        } else {
            
            isMuted = !isMuted
            volumeButton.setImage(UIImage(named: "Mute"), for: UIControlState.normal)
        }
        
        player?.isMuted = isMuted
        
    }
    
   
    
    
    //Observing likes given the id of the post
    
    //Check if user has liked image before. If they have = like filled. If not = like
    
    func updateLike(post: Post) {
        
        let imageName = post.likes == nil  || !post.isLiked! ? "Like1" : "Like Filled1"
        
        likeImageView.image = UIImage(named: imageName)
        
        //Checking and updating Like status
        
        guard let count = post.likeCount else {
            
            return 
            
        }
        
        if count != 0 {
            
            likeCountButton.setTitle("\(count) Respect", for: UIControlState.normal)
            
        } else {
            
            likeCountButton.setTitle("Respect this first!", for: UIControlState.normal)
            
        }
        
    }
    
    //Grabbing all user information its observing and retrieving from specific user uid
    
    func setUserInfo() {
        
        usernameLabel.text = user?.username
        if let photoUrlString = user?.profileImageUrl {
            let photoUrl = URL(string: photoUrlString)
            profileImageView.sd_setImage(with: photoUrl, placeholderImage: UIImage(named: "placeholderImage"))
        }
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.text = ""
        captionLabel.text = ""
        
        //Comment button bubble to comments page
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.commentView_TouchUpInside))
        commentView.addGestureRecognizer(tapGesture)
        commentView.isUserInteractionEnabled = true
        
        let tapGestureForLikeImageView = UITapGestureRecognizer(target: self, action: #selector(self.likeImageView_TouchUpInside))
        likeImageView.addGestureRecognizer(tapGestureForLikeImageView)
        likeImageView.isUserInteractionEnabled = true
        
        let tapGestureForNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.nameLabel_TouchUpInside))
        usernameLabel.addGestureRecognizer(tapGestureForNameLabel)
        usernameLabel.isUserInteractionEnabled = true
        
    }
    

    func nameLabel_TouchUpInside() {
        
        if let id = user?.id {
            
            delegate?.goToProfileUserVC(userId: id)
            
        }
        
    }
        
    
    
    //Like image when pressed sent to database
    
    func likeImageView_TouchUpInside() {
        
        Api.Post.incrementLikes(postId: post!.id!, onSuccess: { (post) in
            self.updateLike(post: post)
            self.post?.likes = post.likes
            self.post?.isLiked = post.isLiked
            self.post?.likeCount = post.likeCount
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
        
        //incrementLikes(forRef: postRef)
        
    }
    
    
    //Comment image to comment view
    
    func commentView_TouchUpInside() {
        print("touched")
        if let id = post?.id {
            
            //Delegate implements how to switch view now
            
            delegate?.goToCommentVC(postId: id)

        }
    }
    
    //Deletes all old data
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("1111")
        
        volumeView.isHidden = true 
        
        profileImageView.image = UIImage(named: "placeholderImage")
        
        playerLayer?.removeFromSuperlayer()
        player?.pause()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

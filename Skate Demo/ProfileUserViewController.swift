//
//  ViewingProfileViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 23/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class ProfileUserViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User!
    
    var posts: [Post] = []
    
    var userId = ""
    
    var delegate: ProfileHeaderCollectionReusableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        print("userId: \(userId)")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        getUser()
        getUserPosts()
        
    }
    
    func getUser() {
        
        Api.User.observeUser(withId: userId) { (user) in
            
            self.isFollowing(userId: user.id!, completed: { (value) in
                
            //Tells us if current user is following user
                
            user.isFollowing = value
                
            //

            self.user = user
            
            self.navigationItem.title = user.username
            
            self.collectionView.reloadData()
                
            })
            
        }
        
    }
    
    func isFollowing(userId: String, completed: @escaping (Bool) -> Void) {
        
        Api.Follow.isFollowing(userId: userId, completed: completed)
        
    }
    
    func getUserPosts() {
        
        Api.userPosts.getUserPosts(userId: userId) { (key) in
            
            Api.Post.observePost(withId: key, completion: {
                post in
                self.posts.append(post)
                self.collectionView.reloadData()
                
            })
            
        }
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        
        if segue.identifier == "ProfileUser_ExpandSegue" {
            let exploreDetailVC = segue.destination as! ExploreDetailViewController
            let postId = sender as! String
            exploreDetailVC.postId = postId
            
        }
        
    }
    
    

}


extension ProfileUserViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        //Display posts at certain array index on corresponding row
        let post = posts[indexPath.row]
        
        cell.post = post
        cell.delegate = self
        
        return cell
    }
    
    //Supply Header to collection view
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerViewCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderCollectionReusableView", for: indexPath) as! ProfileHeaderCollectionReusableView
        if let user = self.user {
            headerViewCell.user = user
            
            headerViewCell.delegate = self.delegate
            
            headerViewCell.delegate2 = self
            
        }
        
        return headerViewCell
    }
    
}

extension ProfileUserViewController: ProfileHeaderCollectionReusableViewDelegateSwitchSettingVC {
    
    func goToSettingVC() {
        
        performSegue(withIdentifier: "ProfileUser_SettingSegue", sender: nil)
        
    }
    
}

//Creating the UI for the cells on profile page

extension ProfileUserViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 , height: collectionView.frame.size.width / 3)
    }
    
}

extension ProfileUserViewController: PhotoCollectionViewCellDelegate {
    
    func goToDetailVC(postId: String) {
        
        performSegue(withIdentifier: "ProfileUser_ExpandSegue", sender: postId)
        
    }
    
}

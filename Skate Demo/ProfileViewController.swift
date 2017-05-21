//
//  ProfileViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 04/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import ProgressHUD


class ProfileViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    



    
    
    var user: User!
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        getUser()
        getUserPosts()
        
        
        navigationController?.navigationBar.barTintColor = UIColor.black
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        
        
        let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.sectionInset = UIEdgeInsetsMake(3, 0, 0, 0)
        
        
        
    }
    
    
    
    //Getting user info and attributes from PHCRView
    
    func getUser() {
        
        Api.User.observeCurrentUser { (user) in
            
            self.user = user
            
            //Set title of the profile controller to that of username
            
            self.navigationItem.title = user.username
            
            self.collectionView.reloadData()
            
        }
        
    }
    
    func getUserPosts() {
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        Api.userPosts.REF_USER_POSTS.child(currentUser.uid).observe(.childAdded, with: {
            snapshot in
            //Data snapshot containing all posts shared by current user or new post just added
            
            Api.Post.observePost(withId: snapshot.key, completion: {
                post in
                self.posts.append(post)
                self.collectionView.reloadData()
                
            })
            
        })
    }
    


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Profile_SettingSegue" {
            let settingVC = segue.destination as! SettingTableViewController
            settingVC.delegate = self
        }
        
        if segue.identifier == "Profile_ExpandSegue" {
            let exploreDetailVC = segue.destination as! ExploreDetailViewController
            let postId = sender as! String
            exploreDetailVC.postId = postId
            
        }
        
    }
    
}

extension ProfileViewController: UICollectionViewDataSource {
    
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
            
            headerViewCell.delegate2 = self
            
        }
        
        return headerViewCell
    }
    
    
    
}

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegateSwitchSettingVC {
    
    func goToSettingVC() {
        
        performSegue(withIdentifier: "Profile_SettingSegue", sender: nil)
        
    }
    
}

//Creating the UI for the cells on profile page

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3 - 2 , height: collectionView.frame.size.width / 3 - 2 )
    }
    
   
    
}

extension ProfileViewController: SettingTableViewControllerDelegate {
    
    func updateUserInfo() {
        self.getUser()
    }
    
}

extension ProfileViewController: PhotoCollectionViewCellDelegate {
    
    func goToDetailVC(postId: String) {
        
        performSegue(withIdentifier: "Profile_ExpandSegue", sender: postId)
        
    }
    
}



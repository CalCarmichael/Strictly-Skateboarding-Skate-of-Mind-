//
//  HashtagViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 15/05/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

class HashtagViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var posts: [Post] = []
    
    var tag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "\(tag)"
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        loadPosts()

        
    }
    
    func loadPosts() {
        
        Api.Hashtag.fetchPostHashtag(withTag: tag) { (postId) in
            
            Api.Post.observePost(withId: postId, completion: { (post) in
                
                self.posts.append(post)
                
                self.collectionView.reloadData()
                
            })
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "HashtagDetail_Segue" {
            let exploreDetailVC = segue.destination as! ExploreDetailViewController
            let postId = sender as! String
            exploreDetailVC.postId = postId
        }
        
    
    }

 
}

extension HashtagViewController: UICollectionViewDataSource {
    
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

}

extension HashtagViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3, height: collectionView.frame.size.width / 3 )
    }
    
}

extension HashtagViewController: PhotoCollectionViewCellDelegate {
    
    func goToDetailVC(postId: String) {
        
        performSegue(withIdentifier: "HashtagDetail_Segue", sender: postId)
        
    }
    
}

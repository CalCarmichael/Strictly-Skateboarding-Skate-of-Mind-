//
//  PhotoCollectionViewCell.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 21/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

protocol PhotoCollectionViewCellDelegate {
    func goToDetailVC(postId: String)
}


class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var Photo: UIImageView!
    
    var delegate: PhotoCollectionViewCellDelegate?
    
    var post: Post? {
        didSet {
            
            updateView()
            
        }
    }
    
    func updateView() {
        
        if let photoUrlString = post?.photoUrl {
            
            let photoUrl = URL(string: photoUrlString)
            Photo.sd_setImage(with: photoUrl)
            
        }
        
        let tapGestureForPhoto = UITapGestureRecognizer(target: self, action: #selector(self.Photo_TouchUpInside))
        Photo.addGestureRecognizer(tapGestureForPhoto)
        Photo.isUserInteractionEnabled = true
        
    }
    
    //Perform segue and deliver post id to detail
    
    func Photo_TouchUpInside() {
    
        
        if let id = post?.id {
            
            delegate?.goToDetailVC(postId: id)
            
        }
        
    }
    
}

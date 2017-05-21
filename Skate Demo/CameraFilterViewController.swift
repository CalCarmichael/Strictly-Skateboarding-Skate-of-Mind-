//
//  CameraFilterViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 12/05/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit

protocol CameraFilterViewControllerDelegate {
    
    func updatePhotoFilter(image: UIImage)
    
}

class CameraFilterViewController: UIViewController {
    
    @IBOutlet weak var filterImage: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var delegate: CameraFilterViewControllerDelegate?
    
    var selectedFilterImage: UIImage!
    
    var CIFilterName = [
    
        "CIColorMap",
        "CIColorMonochrome",
        "CIFalseColor",
        "CIMaximumComponent",
        "CIMinimumComponent",
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectMono",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone",
        "CIVignette",
        "CIVignetteEffect"
    ]
    
    
    var context = CIContext(options: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filterImage.image = selectedFilterImage
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButton_TouchUpInside(_ sender: Any) {
    
    dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func nextButton_TouchUpInside(_ sender: Any) {
    
        dismiss(animated: true, completion: nil)
    
        delegate?.updatePhotoFilter(image: self.filterImage.image!)
        
    
    }
    
    //Resize collection view image so load is quicker
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            
        UIGraphicsEndImageContext()
        
        return newImage!
        
    }
}

extension CameraFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        //Filters from array
        
        return CIFilterName.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as! FilterCollectionViewCell
        
        let newImage = resizeImage(image: selectedFilterImage, newWidth: 150)
        

        
        // Create a filter object from filter class - core image filter class
        
        let ciImage = CIImage(image: newImage)
        
        let filter = CIFilter(name: CIFilterName[indexPath.item])
        
        //Specify corrosponding key so filter knows what putting in
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            
            cell.filterForPhoto.image = UIImage(cgImage: result!)

            
        }
        
        
        return cell
            
            
            
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
        
        let ciImage = CIImage(image: selectedFilterImage)
        
        let filter = CIFilter(name: CIFilterName[indexPath.item])
        
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        
        if let filteredImage = filter?.value(forKey: kCIOutputImageKey) as? CIImage {
            
            let result = context.createCGImage(filteredImage, from: filteredImage.extent)
            
            self.filterImage.image = UIImage(cgImage: result!)
        
    }
        
    }

}
    

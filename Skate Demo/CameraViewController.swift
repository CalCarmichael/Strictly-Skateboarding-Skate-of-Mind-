//
//  CameraViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 04/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import ProgressHUD
import AVFoundation
import ImagePicker

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraImage: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var clearPostButton: UIBarButtonItem!
    
    var selectedImage: UIImage?
    
    var videoUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCameraPhoto))
        cameraImage.addGestureRecognizer(tapGesture)
        cameraImage.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleImagePost()
    }
    
    //Checks if photo is in UIImage. Post button change colour dependant on this.
    
    func handleImagePost() {
        
        if selectedImage != nil {
            
            self.shareButton.isEnabled = true
            self.clearPostButton.isEnabled = true
            self.shareButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
            
        } else {
            
            self.shareButton.isEnabled = false
            self.clearPostButton.isEnabled = false
            self.shareButton.backgroundColor = .lightGray
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //Getting photo
    
    func handleCameraPhoto() {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        //Picker can choose photos and video
        
        pickerController.mediaTypes = ["public.image", "public.movie"]
        
        present(pickerController, animated: true, completion: nil)
        
    }
    
    //Sharing photo
    
    @IBAction func shateButton_TouchUpInside(_ sender: Any) {
        
        view.endEditing(true)
        
        ProgressHUD.show("Waiting...", interaction: false)
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.5) {
                        
            let ratio = profileImg.size.width / profileImg.size.height
            
            HelperService.uploadDataToServer(data: imageData, videoUrl : self.videoUrl, ratio: ratio, caption: captionTextView.text!, onSuccess: {
                
                self.clearPost()
                self.tabBarController?.selectedIndex = 3
                
            })
            
        } else {
            
            ProgressHUD.showError("Profile Image must be chosen")
            
        }
        
    }
    
    //Cancel photo post
    
    @IBAction func remove_TouchUpInside(_ sender: Any) {
        
        clearPost()
        handleImagePost()
        
    }
    
    func clearPost() {
        
        self.captionTextView.text = ""
        self.cameraImage.image = UIImage(named: "image-placeholder")
        self.selectedImage = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageToFilterSegue" {
            
            let filterVC = segue.destination as! CameraFilterViewController
            
            filterVC.selectedFilterImage = self.selectedImage
            
            filterVC.delegate = self
            
        }
    }
    
}

//Getting photo with image picker

extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("did finish pick")
        
        print(info)
        
        //Converting media and saving url
        
        if let videoUrl = info["UIImagePickerControllerMediaURL"] as? URL {
            
            if let thumbnailVideo = self.thumbnailForVideoUrl(videoUrl) {
                
                selectedImage = thumbnailVideo
                cameraImage.image = thumbnailVideo
                self.videoUrl = videoUrl
                
            }
            
            dismiss(animated: true, completion: nil)

            
        }
        
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            cameraImage.image = image
            dismiss(animated: true, completion: { 
                self.performSegue(withIdentifier: "ImageToFilterSegue", sender: nil)
            })
        }
        
    }
    
    func thumbnailForVideoUrl(_ fileUrl: URL) -> UIImage? {
        
        let asset = AVAsset(url: fileUrl)
        
        //Generate thumbnail image
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(6, 3), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
            
        } catch let err {
            print(err)
        }
        
        return nil
        
    }
    
}

extension CameraViewController: CameraFilterViewControllerDelegate {
    
    func updatePhotoFilter(image: UIImage) {
        
        self.cameraImage.image = image
        
    }
    
}

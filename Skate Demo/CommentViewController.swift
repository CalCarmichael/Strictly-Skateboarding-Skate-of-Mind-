//
//  CommentViewController.swift
//  Skate Demo
//
//  Created by Callum Carmichael (i7726422) on 18/04/2017.
//  Copyright © 2017 Callum Carmichael (i7726422). All rights reserved.
//

import UIKit
import ProgressHUD

class CommentViewController: UIViewController {
    
    
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var commentConstrainToBottom: NSLayoutConstraint!
    
    var postId: String!
    
    var comments = [Comment]()
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Comment Page"
        tableView.dataSource = self
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        empty()
        handleTextField()
        loadComments()
        
        //Keyboard for comments page. Showing and hiding and functions for animations 
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    func keyboardWillShow(_ notification: NSNotification) {
        print(notification)
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        print(keyboardFrame)
        UIView.animate(withDuration: 0.25) {
            
            self.commentConstrainToBottom.constant = keyboardFrame!.height
            self.view.layoutIfNeeded()
        }
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            self.commentConstrainToBottom.constant = 0
            self.view.layoutIfNeeded()
    }
        
    }
    
    func loadComments() {
        
        
        
         Api.Post_Comment.REF_POST_COMMENTS.child(self.postId).observe(.childAdded, with: {
            snapshot in
            Api.Comment.observeComments(withPostId: snapshot.key, completion: {
                comment in
                
                self.getUser(uid: comment.uid!, completed: {
                    
                    self.comments.append(comment)
                    
                    self.tableView.reloadData()
                
            })
            
            })
         
        })
        
    }
    
    func getUser(uid: String, completed: @escaping () -> Void) {
        
        Api.User.observeUser(withId: uid, completion: {
            user in
            self.users.append(user)
            completed()
        })
        
    }
    
    
    func handleTextField() {
        
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        if let commentTextField = commentTextField.text, !commentTextField.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false 
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButton_TouchUpInside(_ sender: Any) {
        
        let commentsReference = Api.Comment.REF_COMMENTS
        let newCommentId = commentsReference.childByAutoId().key
        let newCommentReference = commentsReference.child(newCommentId)
        guard let currentUser = Api.User.CURRENT_USER else {
            return
        }
        let currentUserId = currentUser.uid
        newCommentReference.setValue(["uid": currentUserId, "commentText": commentTextField.text!], withCompletionBlock: {
            (error, ref) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            
            let words = self.commentTextField.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            
            for var word in words {
                
                if word.hasPrefix("#") {
                    
                    word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                    
                    let newHashtagRef = Api.Hashtag.REF_HASHTAG.child(word.lowercased())
                    
                    newHashtagRef.updateChildValues([self.postId!: true])
                    
                }
                
                
            }

            
            
            
            let postCommentRef = Api.Post_Comment.REF_POST_COMMENTS.child(self.postId).child(newCommentId)
            postCommentRef.setValue(true, withCompletionBlock: { (error, ref) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
            })
            
            self.empty()
            self.view.endEditing(true)
            
        })
        
        
    }
    
    //Empty out comment message after comment sent
    
    func empty() {
        
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        if segue.identifier == "Comment_ProfileSegue" {
            let profileVC = segue.destination as! ProfileUserViewController
            let userId = sender as! String
            profileVC.userId = userId
        }
        
        if segue.identifier == "Comment_HashtagSegue" {
            let hashtagVC = segue.destination as! HashtagViewController
            let tag = sender as! String
            hashtagVC.tag = tag
        }
        
        
    }
    
    
}
    


extension CommentViewController: UITableViewDataSource {
    
    //Rows in table view - returning posts
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return comments.count
        
    }
    
    //Customise rows
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Reuses the cells shown rather than uploading all of them at once
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        //Posting the user information from Folder Views - FeedTableViewCell
        
        let comment = comments[indexPath.row]
        let user = users[indexPath.row]
        cell.comment = comment
        cell.user = user
        cell.delegate = self
        return cell
    }
    
}

extension CommentViewController: CommentTableViewCellDelegate {
    
    func goToProfileUserVC(userId: String) {
        performSegue(withIdentifier: "Comment_ProfileSegue", sender: userId)
    }
    
    func goToHashtag(tag: String) {
        performSegue(withIdentifier: "Comment_HashtagSegue", sender: tag)
    }
    
}



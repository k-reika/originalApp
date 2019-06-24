//
//  PostTableViewCell.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/06.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PostTableViewCell: UITableViewCell {
    
    var iconimage: UIImage!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadUserInfo()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func loadUserInfo(){
        guard let uid =  Auth.auth().currentUser?.uid else {
            //ログイン画面表示
            return
        }
        let userRef = Database.database().reference().child(Users.UserPath).child(uid)
        userRef.observe(.value, with: { snapshot in
            
            let userData = UserData(snapshot: snapshot, myId: uid)
            self.setUserData(userData)
        })
        
    }
    
    // データをfirebaseから取得し、表示させる
    func setUserData(_ userData: UserData){
        self.iconImageView.image = userData.iconimage
        
        self.userLabel.text = "\(userData.name ?? "") / \(userData.gender ?? "") / \(userData.stature ?? "")cm / \(userData.prefectures ?? "")"
    }
    
    func setPostData(_ postData: PostData) {
        
        self.postImageView.image = postData.image
        
        self.captionLabel.text = "\(postData.caption!)\n"
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let weardate = postData.weardate {
            let weardateString = formatter.string(from: weardate)
            self.dateLabel.text = "着用日：\(weardateString), 天気：\(postData.weather!), 気温：\(postData.temperature!)"
        } else {
            self.dateLabel.text = ""
        }
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
}

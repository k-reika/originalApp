//
//  PostTableViewCell.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/06.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//

import UIKit


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
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUserData(_ userData: UserData){
        self.iconImageView.image = userData.iconimage
        
        self.userLabel.text = "\(userData.name!),\(userData.gender!),\(userData.stature!),\(userData.prefectures!)"
    }
    
    func setPostData(_ postData: PostData) {
        
        self.postImageView.image = postData.image
        
        self.captionLabel.text = "\(postData.caption!)\n"
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
//        // 着用日
//        self.dateLabel.text = "\(postData.weardate!),\(postData.weather!)"
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
}

//
//  PostData.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/06.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PostData: NSObject {
    var id: String?
    var userid: String?
    var image: UIImage?
    var imageString: String?
    
    var caption: String?
    var weather: String?
    var temperature: String?
    var date: Date?
    var weardate: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        imageString = valueDictionary["image"] as? String
        image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        
        self.userid = valueDictionary["userid"] as? String
        
        self.caption = valueDictionary["caption"] as? String
        
        self.weather = valueDictionary["weather"] as? String
        
        self.temperature = valueDictionary["temperature"] as? String
        
        if let time = valueDictionary["weardate"] as? String, let timeInterval = TimeInterval(time) {
            self.weardate = Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        
        if let time = valueDictionary["time"] as? String, let timeInterval = TimeInterval(time) {
            self.date = Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        
        if let likes = valueDictionary["likes"] as? [String] {
            self.likes = likes
        }
        
        for likeId in self.likes {
            if likeId == myId {
                self.isLiked = true
                break
            }
        }
        
        
    }
}

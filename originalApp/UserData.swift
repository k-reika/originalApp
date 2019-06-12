//
//  UserData.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/12.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserData: NSObject {
    var iconimage: UIImage?
    var iconimageString: String?
    var name: String?
    var gender: String?
    var stature: String?
    var prefectures: String?
    
    init(snapshot: DataSnapshot, myId: String) {
//        self.id = snapshot.key
        
        let valueDictionary = snapshot.value as! [String: Any]
        
        iconimageString = valueDictionary["iconimage"] as? String
        iconimage = UIImage(data: Data(base64Encoded: iconimageString!, options: .ignoreUnknownCharacters)!)
        
        self.name = valueDictionary["name"] as? String
        
        self.gender = valueDictionary["name"] as? String
        
        self.stature = valueDictionary["name"] as? String
        
        self.prefectures = valueDictionary["name"] as? String
    }
    
}


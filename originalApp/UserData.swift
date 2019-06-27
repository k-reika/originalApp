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
    var userId: String?
    var iconimage: UIImage?
    var iconimageString: String?
    var name: String?
    var gender: String?
    var stature: String?
    var prefectures: String?
    
    init(snapshot: DataSnapshot, myId: String) {
        
        guard let valueDictionary = snapshot.value as? [String: Any] else {
            return
        }
        
        if let iconimageString = valueDictionary["iconimage"] as? String {
            self.iconimageString = iconimageString
            
            if let data = Data(base64Encoded: iconimageString, options: .ignoreUnknownCharacters) {
                self.iconimage = UIImage(data: data)
            }
        }
        
        userId = myId
        
        self.name = valueDictionary["name"] as? String ?? ""
        
        self.gender = valueDictionary["gender"] as? String  ?? ""
        
        self.stature = valueDictionary["stature"] as? String  ?? ""
        
        self.prefectures = valueDictionary["prefectures"] as? String  ?? ""
    }
    
}


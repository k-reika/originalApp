//
//  MypageCollectionViewController.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/07.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

private let reuseIdentifier = "Cell"

class MypageCollectionViewController: UIViewController {
    
    var iconimage: UIImage!
   
    @IBOutlet weak var iconImageView: NSLayoutConstraint!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBAction func settingButton(_ sender: Any) {
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting")
        self.present(settingViewController!, animated: true, completion: nil)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 受け取った画像をImageViewに設定する
//        iconImageView.image = iconimage
        
        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
}

// MARK: UICollectionViewDataSource

extension MypageCollectionViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = .cyan
        
//        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
//            imageView.image = Firebase.image
//        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MypageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let width = (collectionView.frame.size.width - 1) / 2
        
        return CGSize(width: width, height: width * 1.3)
    }
}

// MARK: UICollectionViewDelegate

extension MypageCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}


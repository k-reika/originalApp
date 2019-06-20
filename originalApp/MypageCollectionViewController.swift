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
    var postArray: [PostData] = []
    
    
//    let ref = Database.database().reference()
   
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
//    @IBOutlet weak var collectionImageView: UIImageView!
    @IBAction func settingButton(_ sender: Any) {
        let settingViewController = self.storyboard?.instantiateViewController(withIdentifier: "Setting")
        self.present(settingViewController!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserInfo()
        loadUserPostData()
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
        
        //firebaseにデータがある時
        self.iconImageView.image = userData.iconimage
        /// プロフィールを表示
        self.userLabel.text = "\(userData.name ?? "") / \(userData.gender ?? "") / \(userData.stature ?? "")cm / \(userData.prefectures ?? "")"
    }
    
    func loadUserPostData() {
        postArray = []
        // uidのnilチェック
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        // postpathを呼び出す
        let  postRef = Database.database().reference().child(Const.PostPath)
        // uidと一致するものを見つける
        let query = postRef.queryOrdered(byChild: "userid").queryEqual(toValue: uid)
        query.observeSingleEvent(of:.value, with: { snapshots in
            
//            print(snapshots)
            
            for snapshot in snapshots.children {
                guard let snapshot = snapshot as? DataSnapshot else { continue }
                let postData = PostData(snapshot: snapshot, myId: uid)
                self.postArray.append(postData)
            }
            self.collectionView.reloadData()
        })
        
        
        // collectionviewを更新する
        self.collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension MypageCollectionViewController: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        let postData = postArray[indexPath.item]
        
        
        
        if let imageView = cell.contentView.viewWithTag(1) as? UIImageView {
            let cellimage = postData.image
            imageView.image = cellimage
        }

        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension MypageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
        let width = (collectionView.frame.size.width - 1) / 2
        print(width)
        let height = width * 4 / 3
        print(height)
        return CGSize(width: width, height: height )
        
    }
}

// MARK: UICollectionViewDelegate

extension MypageCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}


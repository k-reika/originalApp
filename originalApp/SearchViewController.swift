//
//  SearchViewController.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/05.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class SearchViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var postArray: [PostData] = []
    var mySearchBar: UISearchBar!
    var observe = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // デリゲートとデータソースをセット
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        //プレースホルダの指定
        searchBar.placeholder = ""
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        // テーブル行の高さの概算値を設定
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 200
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
    }
    
    // サーチボタンをクリックすると呼び出される
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        
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

            for snapshot in snapshots.children {
                guard let snapshot = snapshot as? DataSnapshot else { continue }
                let postData = PostData(snapshot: snapshot, myId: uid)
                self.postArray.append(postData)
                
                
            }
            print(self.postArray)
            // filterをかける
            let result = self.postArray.filter {
                $0.weather == searchBar.text!
            }
            self.postArray = result
            print(result)
            self.tableView.reloadData()
        })
        
        
        let result = postArray.filter {
            $0.weather == searchBar.text!
        }
        postArray = result
        
        tableView.reloadData()
        
    }
    
    //サーチバーのキャンセルボタンをクリックした時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 画面を閉じる
        self.view.endEditing(true)
        // 検索バーを空にする
        searchBar.text = ""
        postArray = []
        // リロードを行う
        self.tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        // 選択した行にCellを設定する。
        let post = postArray[indexPath.row]
        print(post)
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
            
        }
    }
    
}

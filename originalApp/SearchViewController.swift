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
import DZNEmptyDataSet

class SearchViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var postAllArray: [PostData] = []
    var postArray: [PostData] = []
    var mySearchBar: UISearchBar!
    var observing = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // デリゲートとデータソースをセット
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
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
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostArrayに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する。
                // テーブルをクリアする
                postArray = []
                
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser == nil {
            // ログインしていないときの処理
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
        
        loadData()

        
    }
    
    // サーチボタンをクリックすると呼び出される
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar) {
        
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
        
        postArray = []
        
        // 条件で絞り込む
        var result: [PostData] = []
        for post in self.postAllArray {
            if post.weather == searchBar.text! || post.temperature == searchBar.text! || post.caption == searchBar.text! {
                result.append(post)
            }
        }
        postArray = result
        tableView.reloadData()
        
    }
    
    func loadData() {
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
            
            //            // filterをかける
            //            let result = self.postArray.filter {
            //                $0.weather == searchBar.text!
            //            }
            //
            //            self.postArray = result
            //            print(result)
            self.postAllArray = self.postArray
            self.tableView.reloadData()
        })
        
    }
    
    //サーチバーのキャンセルボタンをクリックした時に呼ばれる
    //サーチバーのキャンセルボタンをクリックした時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 画面を閉じる
        self.view.endEditing(true)
        // 検索バーを空にする
        searchBar.text = ""
        
        postArray = self.postAllArray
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

// 検索結果なしの時に表示したい
extension SearchViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "baseline_search_black_36pt")
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "検索結果は0件です"
        let font = UIFont.boldSystemFont(ofSize: 20)
        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: font])
    }
}

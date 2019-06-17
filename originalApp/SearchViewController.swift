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
    
    var userArray: [UserData] = []
    var mySearchBar: UISearchBar!
    
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
    }
    
    // サーチボタンをクリックすると呼び出される
    func searchBarSearchButtonClicked(_ searchBar:UISearchBar) {
        tableView.reloadData()
    }
    //サーチバーのキャンセルボタンをクリックした時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 画面を閉じる
        self.view.endEditing(true)
        // 検索バーを空にする
        searchBar.text = ""
        // リロードを行う
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArray.count
    }
//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        // Cellに値を設定する。
//        let user = userArray[indexPath.row]
        
        // 再利用可能なcellを得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する。
        _ = userArray[indexPath.row]
        
        return cell
    }
}

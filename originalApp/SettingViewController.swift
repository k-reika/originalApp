//
//  SettingViewController.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/05.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var genderpickerView: UIPickerView = UIPickerView()
    var prefecturespickerView: UIPickerView = UIPickerView()
    var iconimage: UIImage!
    
    let genderlist = ["","男","女"]
    let prefectureslist = ["","北海道","青森","岩手","宮城","秋田","山形","福島","茨城","栃木","群馬","埼玉","千葉","東京","神奈川","新潟","富山","石川","福井","山梨","長野","岐阜","静岡","愛知","三重","滋賀","京都","大阪","兵庫","奈良","和歌山","鳥取","島根","岡山","広島","山口","徳島","香川","愛媛","高知","福岡","佐賀","長崎","熊本","大分","宮崎","鹿児島","沖縄"]
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var statureTextField: UITextField!
    @IBOutlet weak var prefecturesTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBAction func iconImageChangeButton(_ sender: Any) {
//        // アイコン画像選択画面へ遷移する
//        let IconImageSelectViewController = self.storyboard?.instantiateViewController(withIdentifier: "IconImageSelect")
//        self.present(IconImageSelectViewController!, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genderpickerView.delegate = self
        prefecturespickerView.delegate = self
        
        genderpickerView.dataSource = self
        prefecturespickerView.dataSource = self
        
        genderpickerView.showsSelectionIndicator = true
        prefecturespickerView.showsSelectionIndicator = true
        
        // TextFieldにピッカーを搭載する
        genderTextField.inputView = genderpickerView
        prefecturesTextField.inputView = prefecturespickerView
        
        // はじめに表示する項目を指定
        genderpickerView.selectRow(1, inComponent: 0, animated: true)
        prefecturespickerView.selectRow(1, inComponent: 0, animated: true)
        
        // ツールバーに配置するアイテムのインスタンスを作成
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        toolbar.items = [spacer, doneItem]
        
        // テキストフィールドにツールバーを設定
        genderTextField.inputAccessoryView = toolbar
        prefecturesTextField.inputAccessoryView = toolbar
        
        // 受け取った画像をImageViewに設定する
        iconImageView.image = iconimage
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 表示名を取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
    }
    
    // 表示する列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    // アイテム表示個数を返す
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genderpickerView{
        return genderlist.count
        }
        return prefectureslist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 選択時の処理
        if pickerView == genderpickerView{
            genderTextField.text = genderlist[row]
            print(genderlist[row])
        }else{
            prefecturesTextField.text = prefectureslist[row]
            print(prefectureslist[row])
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
        if pickerView == genderpickerView{
            return genderlist[row]
        }
        return prefectureslist[row]
    }
    
    @objc private func done() {
        view.endEditing(true)
//        genderTextField.resignFirstResponder()
//        statureTextField.resignFirstResponder()
    }
    
    @IBAction func handleChangeButton(_ sender: Any) {
//        if let displayName = displayNameTextField.text {
//
//            // 表示名が入力されていない時はHUDを出して何もしない
//            if displayName.isEmpty {
//                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
//                return
//            }
//
//            // 表示名を設定する
//            let user = Auth.auth().currentUser
//            if let user = user {
//                let changeRequest = user.createProfileChangeRequest()
//                changeRequest.displayName = displayName
//                changeRequest.commitChanges { error in
//                    if let error = error {
//                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
//                        print("DEBUG_PRINT: " + error.localizedDescription)
//                        return
//                    }
//                    print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
//
//                    // HUDで完了を知らせる
//                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
//                }
//            }
//        }
        
        // Firebaseに保存する
        guard let uid =  Auth.auth().currentUser?.uid,  let name = Auth.auth().currentUser?.displayName else {
            //ログイン画面表示
            return
        }
        
        //入力がない時、ある時で分岐
        if let gender = genderTextField.text, let stature = statureTextField.text, let prefectures = prefecturesTextField.text,let displayName = displayNameTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if gender.isEmpty || stature.isEmpty || prefectures.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            // HUDで処理中を表示
            SVProgressHUD.show()
            
        }
        
        // ImageViewから画像を取得する
        let iconimageData = iconImageView.image!.jpegData(compressionQuality: 0.5)
        let iconimageString = iconimageData!.base64EncodedString(options: .lineLength64Characters)
        
//        // postDataに必要な情報を取得しておく
//        let time = Date.timeIntervalSinceReferenceDate
//        let name = Auth.auth().currentUser?.displayName

        // 辞書を作成してFirebaseに保存する
        let userRef = Database.database().reference().child(Users.UserPath).child(uid)
        let userDic = ["iconimage": iconimageString, "gender": genderTextField.text!,"stature": statureTextField.text!,"prefecture":prefecturesTextField.text!, "name": name]
        userRef.setValue(userDic)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "登録しました")
        
        // キーボードを閉じる
        self.view.endEditing(true)
        
        // マイページに戻る
//        dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    
    }
    
    @IBAction func handleLogoutButton(_ sender: Any) {
        // ログアウトする
        try! Auth.auth().signOut()
        
        // ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        // ログイン画面から戻ってきた時のためにホーム画面（index = 0）を選択している状態にしておく
        self.navigationController!.tabBarController!.selectedIndex = 0
        
     
    }
    
    
   
}

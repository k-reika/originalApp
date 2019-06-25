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
import CLImageEditor

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    
    var genderpickerView: UIPickerView = UIPickerView()
    var prefecturespickerView: UIPickerView = UIPickerView()
    var iconimage: UIImage!
    var userData: [UserData] = []
    
    let genderlist = ["","MEN","WOMEN"]
    let prefectureslist = ["","北海道","青森","岩手","宮城","秋田","山形","福島","茨城","栃木","群馬","埼玉","千葉","東京","神奈川","新潟","富山","石川","福井","山梨","長野","岐阜","静岡","愛知","三重","滋賀","京都","大阪","兵庫","奈良","和歌山","鳥取","島根","岡山","広島","山口","徳島","香川","愛媛","高知","福岡","佐賀","長崎","熊本","大分","宮崎","鹿児島","沖縄"]
    
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var statureTextField: UITextField!
    @IBOutlet weak var prefecturesTextField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    
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
        let doneItem = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(done))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        toolbar.barStyle = .default
        toolbar.sizeToFit()
        toolbar.items = [spacer, doneItem]
        
        // テキストフィールドにツールバーを設定
        genderTextField.inputAccessoryView = toolbar
        prefecturesTextField.inputAccessoryView = toolbar
        
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
        
//        displayNameTextField.text = userData.name
//        genderTextField.text = userData.gender
//        prefecturesTextField.text = userData.prefectures
//        statureTextField.text = userData.stature
        
        let iconimageView = UIImageView()
        let iconimage = UIImage(named: "baseline_account_box_black_48pt")
        iconimageView.image = iconimage
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 表示名を取得してTextFieldに設定する
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
        
//        // すでに登録情報がある場合はデータを表示する
//        if let stature = statureTextField.text{
//
//        }
    }
    
    // Firebaseに保存する
    @IBAction func handleChangeButton(_ sender: Any) {
        
        guard let uid =  Auth.auth().currentUser?.uid,  let name = Auth.auth().currentUser?.displayName else {
            //ログイン画面表示
            if Auth.auth().currentUser == nil {
                // ログインしていないときの処理
                let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
                self.present(loginViewController!, animated: true, completion: nil)
            }
            
            return
        }
        //入力がない時、ある時で分岐
        if  let stature = statureTextField.text, let prefectures = prefecturesTextField.text,let displayName = displayNameTextField.text {
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if stature.isEmpty{
                SVProgressHUD.showError(withStatus: "身長を入力して下さい")
                return
            }
            if prefectures.isEmpty{
                SVProgressHUD.showError(withStatus: "都道府県を入力して下さい")
                return
            }
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "名前を入力して下さい")
                return
            }else{
                // ImageViewから画像を取得する
                let image = iconImageView.image
                let iconimageData = image!.jpegData(compressionQuality: 0.5)
                let iconimageString = iconimageData!.base64EncodedString(options: .lineLength64Characters)
             
                // 辞書を作成してFirebaseに保存する
                let userRef = Database.database().reference().child(Users.UserPath).child(uid)
                let userDic = ["iconimage": iconimageString, "gender": genderTextField.text!,"stature": statureTextField.text!,"prefectures":prefecturesTextField.text!, "name": name]
                userRef.setValue(userDic)
                
                // HUDで投稿完了を表示する
                SVProgressHUD.showSuccess(withStatus: "登録しました")
                
                // キーボードを閉じる
                self.view.endEditing(true)
    
                if presentingViewController != nil {
                    // 全てのモーダルを閉じる
                    UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
                } else {
                    navigationController?.popViewController(animated: true)
                    
                }
            }
        }
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
    
    @IBAction func iconImageChangeButton(_ sender: Any) {
        // styleをActionSheetに設定
        let alertSheet = UIAlertController(title: "", message: "プロフィール写真を変更", preferredStyle: UIAlertController.Style.actionSheet)
        
        // 自分の選択肢を生成
        let action1 = UIAlertAction(title: "現在の画像を削除", style: UIAlertAction.Style.destructive, handler: {
            (action: UIAlertAction!) in
            self.iconImageView.image = nil
            self.iconImageView.setNeedsDisplay()
            self.iconImageView.layoutIfNeeded()
        })
        let action2 = UIAlertAction(title: "ライブラリから選択", style: UIAlertAction.Style.default, handler: {
            (action: UIAlertAction!) in
            // ライブラリ（カメラロール）を指定してピッカーを開く
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = .photoLibrary
                self.present(pickerController, animated: true, completion: nil)
            }
        })
        let action3 = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        // アクションを追加.
        alertSheet.addAction(action1)
        alertSheet.addAction(action2)
        alertSheet.addAction(action3)
        
        self.present(alertSheet, animated: true, completion: nil)
        
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            
            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            picker.pushViewController(editor, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 閉じる
        picker.dismiss(animated: true, completion: nil)
    }
    
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith SelectImage: UIImage!) {
        // 受け取った画像をImageViewに設定する
        iconImageView.image = SelectImage
       
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func done() {
        view.endEditing(true)

    }
    
    
    
   
}

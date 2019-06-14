//
//  PostViewController.swift
//  originalApp
//
//  Created by 菊池 玲花 on 2019/06/05.
//  Copyright © 2019 reika.kikuchi. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class PostViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var image: UIImage!
    var weatherpickerView: UIPickerView = UIPickerView()
    //UIDatePickerを定義するための変数
    var weardatePicker: UIDatePicker = UIDatePicker()
    let weatherlist = ["","晴れ","曇り","雨","雪"]
    
    var tapTextfieldIndex: Int = 0
    var activeTextFiled: UITextField?
    var selectedDate: Date?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var weatherTextField: UITextField!
    @IBOutlet weak var temperatureTextField: UITextField!
    @IBOutlet weak var weardateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherpickerView.delegate = self
        weatherpickerView.dataSource = self
        weatherTextField.delegate = self
        weardateTextField.delegate = self
        
        weatherpickerView.showsSelectionIndicator = true
        weatherTextField.inputView = weatherpickerView
        weatherpickerView.selectRow(1, inComponent: 0, animated: true)
        
        // ピッカー設定
        weardatePicker.datePickerMode = UIDatePicker.Mode.date
        weardatePicker.timeZone = NSTimeZone.local
        weardatePicker.locale = Locale.current
        weardateTextField.inputView = weardatePicker
        
        // 決定バーの生成
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 40))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        // ツールバー設定
        weatherTextField.inputAccessoryView = toolbar
        weardateTextField.inputAccessoryView = toolbar
        
        // 受け取った画像をImageViewに設定する
        imageView.image = image
        
        // 選んだ日付
        selectedDate = weardatePicker.date
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return weatherlist.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 選択時の処理
        weatherTextField.text = weatherlist[row]
        print(weatherlist[row])
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // 表示する文字列を返す
       return weatherlist[row]
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextFiled = textField
        
    }
    
    // UIDatePickerのDoneを押したら
    @objc func done() {
        if activeTextFiled == weatherTextField {
            weatherTextField.resignFirstResponder()
            // weatherTextField.text = weatherpickerView.selectedRow(inComponent: )
        } else if activeTextFiled == weardateTextField {
            weardateTextField.resignFirstResponder()
            
            // 日付のフォーマット
            let formatter = DateFormatter()
            //出力の仕方を変更
            formatter.dateFormat = "yyyy.MM.dd"
            //(from: datePicker.date))を指定してあげることで
            //datePickerで指定した日付が表示される
            weardateTextField.text = "\(formatter.string(from: weardatePicker.date))"
            print(weardateTextField.text!)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func haundleCancelButton(_ sender: Any) {
        // 画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
        guard let selectedDate = selectedDate else {
            //日付選択してください。
            return
        }
        
        // ImageViewから画像を取得する
        let imageData = imageView.image!.jpegData(compressionQuality: 0.5)
        let imageString = imageData!.base64EncodedString(options: .lineLength64Characters)
        
        // postDataに必要な情報を取得しておく
        let time = Date.timeIntervalSinceReferenceDate
        let name = Auth.auth().currentUser?.displayName
        let weardate = selectedDate.timeIntervalSinceReferenceDate
        let userid = Auth.auth().currentUser?.uid

        // 辞書を作成してFirebaseに保存する
        let postRef = Database.database().reference().child(Const.PostPath)
        let postDic = ["caption": captionTextView.text!, "image": imageString, "weather": weatherTextField.text!,"temperature": temperatureTextField.text!, "time": String(time), "weardate": String(weardate),"name": name!,"userid": userid!]
        postRef.childByAutoId().setValue(postDic)
        
        // HUDで投稿完了を表示する
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        
        // 全てのモーダルを閉じる
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
}




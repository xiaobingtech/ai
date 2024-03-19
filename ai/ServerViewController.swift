//
//  ServerViewController.swift
//  
//
//  Created by 范东 on 2022/5/11.
//

import UIKit

class ServerViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
    }
    

    lazy var textField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.returnKeyType = .done
        textField.delegate = self
        textField.placeholder = "请输入神秘代码"
        textField.borderStyle = .roundedRect
        return textField
    }()

}

extension ServerViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ?? 0 > 0 {
            let serverURL = UserDefaults.standard.string(forKey: .serverURL)
            UserDefaults.standard.setValue(textField.text, forKey: .serverURL)
            UserDefaults.standard.synchronize()
            if serverURL?.count ?? 0 > 0 {
                perform(Selector.init(stringLiteral: "terminate"))
            }else{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: .serverURL), object: nil)
            }
        }
        return true
    }
}

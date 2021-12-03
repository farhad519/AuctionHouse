//
//  SignUpViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/12/21.
//

import UIKit

class SignUpViewController: UIViewController {
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var gmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = UIColor(hex: "097969")
        signUpButton.layer.cornerRadius = 20
    }
    
//    override func viewDidLayoutSubviews() {
//        //super.viewDidLayoutSubviews()
//        styleTextField(textField: userName)
//        styleTextField(textField: gmail)
//        styleTextField(textField: password)
//    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
    }
    
    private func styleTextField(textField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(
            x: 0,
            y: textField.frame.height - 2,
            width: textField.frame.width,
            height: 2
        )
        bottomLine.backgroundColor = UIColor(
            red: 48 / 255,
            green: 173 / 255,
            blue: 99 / 255,
            alpha: 1
        ).cgColor
        textField.borderStyle = .none
        textField.layer.addSublayer(bottomLine)
    }
}

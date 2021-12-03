//
//  SignInViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/12/21.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.backgroundColor = UIColor(hex: "097969")
        signInButton.layer.cornerRadius = 20
    }
    @IBAction func signInButtonAction(_ sender: Any) {
    }
}

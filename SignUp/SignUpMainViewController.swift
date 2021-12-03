//
//  SignUpMainViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/12/21.
//

import UIKit

class SignUpMainViewController: UIViewController {
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.backgroundColor = UIColor(hex: "097969")
        signUpButton.backgroundColor = UIColor(hex: "097969")
        signInButton.layer.cornerRadius = 23
        signUpButton.layer.cornerRadius = 23
    }
    @IBAction func moveToSignInPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func moveToSignUpPage(_ sender: Any) {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}

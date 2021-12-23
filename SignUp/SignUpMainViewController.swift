//
//  SignUpMainViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/12/21.
//

import UIKit
import ReactiveSwift

class SignUpMainViewController: UIViewController {
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var viewModel: SignUpMainViewModel!
    
    static func makeViewController() -> SignUpMainViewController {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpMainViewController") as? SignUpMainViewController
        vc?.viewModel = SignUpMainViewModel()
        return vc ?? SignUpMainViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.isNavigationBarHidden = false
        navigationItem.backButtonTitle = "back"

        signInButton.backgroundColor = UIColor(hex: "097969")
        signUpButton.backgroundColor = UIColor(hex: "097969")
        signInButton.layer.cornerRadius = 23
        signUpButton.layer.cornerRadius = 23
    }
    @IBAction func moveToSignInPage(_ sender: Any) {
        let vc = SignInViewController.makeViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func moveToSignUpPage(_ sender: Any) {
        let vc = SignUpViewController.makeViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

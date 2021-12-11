//
//  SignUpViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/12/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var gmail: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var viewModel: SignUpMainViewModel!
    
    static func makeViewController(viewModel: SignUpMainViewModel) -> SignUpViewController {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        vc?.viewModel = viewModel
        return vc ?? SignUpViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = UIColor(hex: "097969")
        signUpButton.layer.cornerRadius = 20
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .black
    }
    
    @IBAction func signUpButtonAction(_ sender: Any) {
        if let error = viewModel.validateFields(
            userName: userName.text,
            gmail: gmail.text,
            password: password.text
        ) {
            errorLabel.text = error
            return
        } else {
            errorLabel.text = ""
        }
        
        guard let userName = userName.text, let email = gmail.text, let password = password.text else {
            return
        }
        GlobalUITask.showSpinner(viewController: self)
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let self = self else {
                GlobalUITask.removeSpinner(viewController: self ?? UIViewController())
                return
            }
            if let error = error {
                GlobalUITask.removeSpinner(viewController: self)
                self.errorLabel.text = "error at creating user with \(error.localizedDescription)"
            } else {
                guard let uid = authResult?.user.uid else { return }
                let db = Firestore.firestore()
                db
                    .collection("users")
                    .addDocument(
                        data: ["email": email, "userName": userName, "uid": uid]
                    ) { error in
                        if let error = error {
                            GlobalUITask.removeSpinner(viewController: self)
                            self.errorLabel.text = "error at saving user with \( error.localizedDescription)"
                        } else {
                            //Toast.show(message: "Successful sign up.", controller: self ?? UIViewController())
                            authResult?.user.sendEmailVerification { error in
                                GlobalUITask.removeSpinner(viewController: self)
                                if let error = error {
                                    Toast.show(message: "\(error)", controller: self)
                                } else {
                                    Toast.show(message: "A email link has been sent to the given email. Please verify the email.", controller: self)
                                }
                            }
                        }
                }
            }
        }
    }
    
//    private func styleTextField(textField: UITextField) {
//        let bottomLine = CALayer()
//        bottomLine.frame = CGRect(
//            x: 0,
//            y: textField.frame.height - 2,
//            width: textField.frame.width,
//            height: 2
//        )
//        bottomLine.backgroundColor = UIColor(
//            red: 48 / 255,
//            green: 173 / 255,
//            blue: 99 / 255,
//            alpha: 1
//        ).cgColor
//        textField.borderStyle = .none
//        textField.layer.addSublayer(bottomLine)
//    }
}

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
    @IBOutlet weak var stackViewContainer: UIStackView!
    
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    
    var viewModel: SignUpMainViewModel!
    
    static func makeViewController(viewModel: SignUpMainViewModel) -> SignUpViewController {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController
        vc?.viewModel = viewModel
        return vc ?? SignUpViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackViewContainer.backgroundColor = color.groundLevelColor
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.backgroundColor = color.firstLevelColor
        signUpButton.layer.cornerRadius = 20
        
        userName.backgroundColor = color.secondLevelColor
        gmail.backgroundColor = color.secondLevelColor
        password.backgroundColor = color.secondLevelColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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

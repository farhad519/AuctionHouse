//
//  SignInViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/12/21.
//

import FirebaseAuth
import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var stackViewContainer: UIStackView!
    
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    
    var viewModel: SignUpMainViewModel!
    
    static func makeViewController(viewModel: SignUpMainViewModel) -> SignInViewController {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
        vc?.viewModel = viewModel
        return vc ?? SignInViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stackViewContainer.backgroundColor = color.groundLevelColor
        signInButton.backgroundColor = color.firstLevelColor
        signInButton.layer.cornerRadius = 20
        email.backgroundColor = color.secondLevelColor
        password.backgroundColor = color.secondLevelColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        email.text = viewModel.email
        password.text = viewModel.passward
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
    
    @IBAction func signInButtonAction(_ sender: UIButton) {
        guard
            let email = email.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = password.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            else {
                errorLabel.text = "Reload the page"
                return
            }
        viewModel.email = email
        viewModel.passward = password
        GlobalUITask.showSpinner(viewController: self)
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            GlobalUITask.removeSpinner(viewController: self ?? UIViewController())
            guard error == nil else {
                let errorText = error?.localizedDescription ?? "Error with sign in."
                self?.errorLabel.text = errorText
                return
            }
            
            //if let value = authResult?.user.isEmailVerified, value == true {
                Toast.show(message: "successful sign in.", controller: self ?? UIViewController())
                let vc = DashboardViewController()
                self?.navigationController?.pushViewController(vc, animated: true)
            //} else {
                Toast.show(message: "email not verified.", controller: self ?? UIViewController())
            //}
        }
    }
}

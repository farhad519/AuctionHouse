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
    @IBOutlet weak var stackViewContainer: UIStackView!
    
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    
    var viewModel: SignUpMainViewModel!
    
    static func makeViewController() -> SignUpMainViewController {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SignUpMainViewController") as? SignUpMainViewController
        vc?.viewModel = SignUpMainViewModel()
        return vc ?? SignUpMainViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataCollector().getAllSellList()
        //DataCollector().postRecentMessages(message: "hi there ee", iconUrl: "", toId: "jZyx5PCCtDV95lFExJQ4RtYHjIR2")
        //let vm = ContactListViewModel()
        //vm.fetchData()
        //navigationController?.pushViewController(ChatViewController.makeViewController(toId: ""), animated: true)
        
        stackViewContainer.backgroundColor = color.groundLevelColor
        signInButton.backgroundColor = color.firstLevelColor
        signUpButton.backgroundColor = color.firstLevelColor
        signInButton.layer.cornerRadius = 23
        signUpButton.layer.cornerRadius = 23
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
    
    @IBAction func moveToSignInPage(_ sender: Any) {
        let vc = SignInViewController.makeViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func moveToSignUpPage(_ sender: Any) {
        let vc = SignUpViewController.makeViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

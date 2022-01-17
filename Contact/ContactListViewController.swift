//
//  ContactListViewController.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 26/10/21.
//

import UIKit
import ReactiveSwift

class ContactListViewController: UIViewController {
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    var tableView = UITableView(frame: .zero, style: .grouped)
    
    private var disposables = CompositeDisposable()
    private var viewModel: ContactListViewModel!
    
    private let tableViewCellId = "ContactCell"
    
    static func makeViewController() -> ContactListViewController {
        let vc = ContactListViewController()
        vc.viewModel = ContactListViewModel(vc: vc)
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfWidth = self.view.frame.width
        selfHeight = self.view.frame.height
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disposables += viewModel.fetchData()
        disposables += viewModel.observeForUpdate.startWithValues { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposables.dispose()
    }
    
    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = CGRect(
            origin: .zero,
            size: self.view.frame.size
        )
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.register(BuyDetailsCell.self, forCellReuseIdentifier: tableViewCellId)
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ContactCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: tableViewCellId)
        self.view.addSubview(tableView)
    }
    
    @objc private func detailsButtonAction() {
        let actionController = UIAlertController(
            title: "Details",
            message: "This is details but also inside more details please check.",
            preferredStyle: .alert
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default,
                handler: nil
            )
        )
        
        present(actionController, animated: true)
    }
}

extension ContactListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.contactList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellId, for: indexPath) as! ContactCell
        
        guard indexPath.item < viewModel.contactList.count else {
            return cell
        }
        let contactItem = viewModel.contactList[indexPath.item]
        
        cell.contactCellImageView.image = UIImage(named: "img1")
        cell.contactCellImageView?.backgroundColor = .black
        cell.contactCellImageView?.layer.cornerRadius = 10
        
        cell.titleLabel.font = UIFont(name: "Helvetica", size: 20)!
        cell.titleLabel.text = contactItem.email
        
        cell.subtitleLabel.font = UIFont(name: "Helvetica", size: 12)!
        cell.subtitleLabel.numberOfLines = 0
        cell.subtitleLabel.text = contactItem.message
        
        cell.upperLabel.font = UIFont(name: "Helvetica", size: 10)!
        cell.upperLabel.text = "Last message"
        
        let date = Date(timeIntervalSince1970: TimeInterval(truncating: contactItem.timeStamp))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.lowerLabel.font = UIFont(name: "Helvetica", size: 10)!
        cell.lowerLabel.text = dateFormatter.string(from: date)
        
        //cell.newLabel.layer.borderWidth = 0.1
        cell.newLabel.layer.cornerRadius = 10
        cell.newLabel.clipsToBounds = true
        cell.newLabel.backgroundColor = .orange
        cell.newLabel.font = UIFont(name: "Helvetica", size: 15)!
        cell.newLabel.textColor = .white
        cell.newLabel.text = "N"
        
        return cell
    }
}

extension ContactListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatMesengerViewController.makeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#ededed", alpha: 1)
        return view
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#ededed", alpha: 1)
        return view
    }
}

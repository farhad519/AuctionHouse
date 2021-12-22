//
//  AuctionListViewController.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 15/10/21.
//

import UIKit

class AuctionListViewController: UIViewController {
    private let headerHeight: CGFloat = 200
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private let tableViewCellId = "AuctionListCell"
    
    private let leftSearchViewPlaceHolder = TextViewPlaceHolder("Min cost")
    private let rightSearchViewPlaceHolder = TextViewPlaceHolder("Max cost")
    private let searchViewPlaceHolder = TextViewPlaceHolder("Write search key word by comma.")
    private let searchView = UITextView()
    private let leftSearchView = UITextView()
    private let rightSearchView = UITextView()
    private let pageNumLabel = UILabel()
    private var viewModel: AuctionListViewModel!
    
    static func makeViewController(auctionListViewType: AuctionListViewType) -> AuctionListViewController {
        let vc = AuctionListViewController()
        vc.viewModel = AuctionListViewModel(auctionListViewType: auctionListViewType)
        vc.viewModel.delegate = vc
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfWidth = self.view.frame.width
        selfHeight = self.view.frame.height
        configureTableView()
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
        let nib = UINib(nibName: "AuctionListCell", bundle: bundle)
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

extension AuctionListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.auctionSellItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellId, for: indexPath) as! AuctionListCell
        let item = viewModel.getItem(at: indexPath.item)
        
        cell.buyImageView.image = item.image
        cell.buyImageView.backgroundColor = .black
        cell.buyImageView?.layer.cornerRadius = 10
        cell.buyImageView.contentMode = .scaleAspectFill
        
        cell.upperLabel.text = item.upperString
        cell.upperLabel.backgroundColor = .clear
        cell.lowerLabel.text = item.lowerString
        cell.lowerLabel.backgroundColor = .clear
        
        cell.arrowLabel.text = ">"
        cell.arrowLabel.backgroundColor = .clear
        
        cell.detailsButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)!
        cell.detailsButton.setTitle("?", for: .normal)
        cell.detailsButton.layer.cornerRadius = 20
        cell.detailsButton.backgroundColor = UIColor(hex: "#c6c6c6", alpha: 1)
        cell.detailsButton.setTitleColor(.white, for: .highlighted)
        cell.detailsButton.addTarget(
            self,
            action: #selector(detailsButtonAction),
            for: .touchUpInside
        )
        
        return cell
    }
}

extension AuctionListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.auctionListViewType {
        case .bidListView:
            return 30
        case .createdView:
            return 30
        case .auctionListView:
            return headerHeight
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.auctionListViewType {
        case .bidListView:
            let view = UIView()
            view.backgroundColor = .white
            return view
        case .createdView:
            let view = UIView()
            view.backgroundColor = .white
            return view
        case .auctionListView:
            let view = prepareHeaderView()
            view.backgroundColor = UIColor(hex: "#ededed", alpha: 1)
            return view
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }
}

extension AuctionListViewController {
    private func prepareHeaderView() -> UIView {
        let searchButtonHeight: CGFloat = 35
        let searchViewHeight: CGFloat = 35
        let buttonSize: CGFloat = 35
        let buttonInset: CGFloat = 10
        let textViewEdgeInset: CGFloat = 5
        let maxMinSearchViewHeight: CGFloat = 35
        let maxMinSearchViewWidth: CGFloat = (selfWidth - (3 * buttonInset)) / 2
        
        let headerView = UIView()
        headerView.frame = CGRect(
            x: 0,
            y: 0,
            width: selfWidth,
            height: headerHeight
        )
        
        // Left right page button
        let leftButton = UIButton()
        leftButton.backgroundColor = .blue
        leftButton.frame = CGRect(
            x: buttonInset,
            y: headerHeight - buttonSize - buttonInset,
            width: buttonSize,
            height: buttonSize
        )
        leftButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)!
        leftButton.setTitle("<", for: .normal)
        leftButton.backgroundColor = .clear
        leftButton.setTitleColor(.black, for: .normal)
        leftButton.setTitleColor(.white, for: .highlighted)
        leftButton.addTarget(
            self,
            action: #selector(leftArrowButtonAction),
            for: .touchUpInside
        )
        headerView.addSubview(leftButton)
        
        let rightButton = UIButton()
        rightButton.backgroundColor = .blue
        rightButton.frame = CGRect(
            x: selfWidth - buttonSize - buttonInset,
            y: headerHeight - buttonSize - buttonInset,
            width: buttonSize,
            height: buttonSize
        )
        rightButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)!
        rightButton.setTitle(">", for: .normal)
        rightButton.backgroundColor = .clear
        rightButton.setTitleColor(.black, for: .normal)
        rightButton.setTitleColor(.white, for: .highlighted)
        rightButton.addTarget(
            self,
            action: #selector(rightArrowButtonAction),
            for: .touchUpInside
        )
        headerView.addSubview(rightButton)
        
        // page number label
        pageNumLabel.text = "1"
        pageNumLabel.frame = CGRect(
            x: (selfWidth / 2) - (buttonSize / 2),
            y: headerHeight - buttonSize - buttonInset,
            width: buttonSize,
            height: buttonSize
        )
        headerView.addSubview(pageNumLabel)
        
        // search button
        let searchButton = UIButton()
        searchButton.frame = CGRect(
            x: buttonInset,
            y: headerHeight - buttonSize - (2 * buttonInset) - searchButtonHeight,
            width: selfWidth - (2 * buttonInset),
            height: searchButtonHeight
        )
        searchButton.layer.cornerRadius = 10
        searchButton.backgroundColor = .blue
        searchButton.setTitle("Search", for: .normal)
        searchButton.setTitleColor(.lightGray, for: .highlighted)
        searchButton.addTarget(
            self,
            action: #selector(searchButtonAction),
            for: .touchUpInside
        )
        headerView.addSubview(searchButton)
        
        // The upper 3 search view
        searchView.frame = CGRect(
            x: buttonInset,
            y: headerHeight - buttonSize - (3 * buttonInset) - searchViewHeight - searchButtonHeight,
            width: selfWidth - (2 * buttonInset),
            height: searchViewHeight
        )
        searchView.layer.cornerRadius = 10
        searchView.textContainerInset = UIEdgeInsets(
            top: textViewEdgeInset,
            left: textViewEdgeInset,
            bottom: textViewEdgeInset,
            right: textViewEdgeInset
        )
        let textViewFont: UIFont = UIFont(name: "Helvetica", size: 18)!
        searchView.font = textViewFont
        searchView.isScrollEnabled = false
        searchView.textContainer.lineFragmentPadding = 0
        searchView.delegate = searchViewPlaceHolder
        searchView.text = searchViewPlaceHolder.placeHolderString
        searchView.textColor = .lightGray
        headerView.addSubview(searchView)
        
        
        leftSearchView.frame = CGRect(
            x: buttonInset,
            y: headerHeight - buttonSize - (4 * buttonInset) - searchViewHeight - searchButtonHeight - maxMinSearchViewHeight,
            width: maxMinSearchViewWidth,
            height: maxMinSearchViewHeight
        )
        leftSearchView.layer.cornerRadius = 10
        leftSearchView.textContainerInset = UIEdgeInsets(
            top: textViewEdgeInset,
            left: textViewEdgeInset,
            bottom: textViewEdgeInset,
            right: textViewEdgeInset
        )
        let leftTextViewFont: UIFont = UIFont(name: "Helvetica", size: 18)!
        leftSearchView.font = leftTextViewFont
        leftSearchView.isScrollEnabled = false
        leftSearchView.textContainer.lineFragmentPadding = 0
        leftSearchView.delegate = leftSearchViewPlaceHolder
        leftSearchView.text = leftSearchViewPlaceHolder.placeHolderString
        leftSearchView.textColor = .lightGray
        headerView.addSubview(leftSearchView)
        
        
        rightSearchView.frame = CGRect(
            x: (2 * buttonInset) + maxMinSearchViewWidth,
            y: headerHeight - buttonSize - (4 * buttonInset) - searchViewHeight - searchButtonHeight - maxMinSearchViewHeight,
            width: maxMinSearchViewWidth,
            height: maxMinSearchViewHeight
        )
        rightSearchView.layer.cornerRadius = 10
        //rightSearchView.layer.borderWidth = 1
        rightSearchView.textContainerInset = UIEdgeInsets(
            top: textViewEdgeInset,
            left: textViewEdgeInset,
            bottom: textViewEdgeInset,
            right: textViewEdgeInset
        )
        let rightTextViewFont: UIFont = UIFont(name: "Helvetica", size: 18)!
        rightSearchView.font = rightTextViewFont
        rightSearchView.isScrollEnabled = false
        rightSearchView.textContainer.lineFragmentPadding = 0
        rightSearchView.delegate = rightSearchViewPlaceHolder
        rightSearchView.text = rightSearchViewPlaceHolder.placeHolderString
        rightSearchView.textColor = .lightGray
        headerView.addSubview(rightSearchView)
        
        return headerView
    }
    
    @objc private func searchButtonAction() {
        var minCost: Double = 0
        var maxCost: Double = 99999999
        var trimmedString = String(
            searchView.text.filter { !" \n\t\r".contains($0) }
        )
        if searchView.textColor == .lightGray {
            trimmedString = ""
        }
        let keyArrs = trimmedString.components(separatedBy: ",")
        
        if let value = Double(leftSearchView.text) {
            minCost = value
        }
        if let value = Double(rightSearchView.text) {
            maxCost = value
        }
        
        print(minCost)
        print(maxCost)
        print(keyArrs)
    }
    
    @objc private func leftArrowButtonAction() {
        var curNum = Int(pageNumLabel.text ?? "1") ?? 1
        if curNum > 1 {
            curNum = curNum - 1
        }
        pageNumLabel.text = "\(curNum)"
    }
    
    @objc private func rightArrowButtonAction() {
        var curNum = Int(pageNumLabel.text ?? "1") ?? 1
        if curNum < 10 {
            curNum = curNum + 1
        }
        pageNumLabel.text = "\(curNum)"
    }
}

extension AuctionListViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AuctionListViewController: AuctionListViewControllerDelegate {
    func reloadViewController() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

class TextViewPlaceHolder: NSObject {
    var placeHolderString: String
    
    init(_ placeHolderString: String) {
        self.placeHolderString = placeHolderString
    }
    
    private func isEmpty(string: String) -> Bool {
        for ch in string {
            if ch != "\n" && ch != " " {
                return false
            }
            return true
        }
        return true
    }
}

extension TextViewPlaceHolder: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if isEmpty(string: textView.text) {
            textView.text = placeHolderString
            textView.textColor = UIColor.lightGray
        }
    }
}

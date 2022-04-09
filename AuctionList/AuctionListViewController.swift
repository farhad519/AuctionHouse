//
//  AuctionListViewController.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 15/10/21.
//

import UIKit
import ReactiveSwift

class AuctionListViewController: UIViewController {
    private var headerHeight: CGFloat = 210
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private var upperExtraHeight: CGFloat = 0.0
    private var tableView = UITableView(frame: .zero, style: .grouped)
    
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    
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
        upperExtraHeight = (navigationController?.navigationBar.frame.height ?? 0) + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        configureTableView()
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
    
    private func configureTableView() {
        prepareHeaderView()
        
        tableView.backgroundColor = color.groundLevelColor
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.register(BuyDetailsCell.self, forCellReuseIdentifier: tableViewCellId)
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AuctionListCell", bundle: bundle)
        tableView.register(nib, forCellReuseIdentifier: tableViewCellId)
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: headerHeight),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func detailsButtonAction(sender: UIButton) {
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
        let description = viewModel.getCellItem(at: indexPath?.item ?? viewModel.auctionSellItemList.count).sellDescription
        
        //print("\(String(describing: indexPath))")
        let actionController = UIAlertController(
            title: "Details",
            message: description,
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
        cell.backgroundColor = color.firstLevelColor
        let item = viewModel.getCellItem(at: indexPath.item)
        //print("dammamamamam = \(item.imageUrlString)")
        cell.buyImageView.image = nil
        viewModel.fetchImageSignal(urlString: item.imageUrlString)
            .startWithResult { [weak cell] result in
                print("EEEEE = \(cell == nil)")
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        cell?.buyImageView.image = image
                    }
                case .failure(let error):
                    print("[AuctionListViewController][cellForRowAt] error at fetching image \(error)")
                }
            }
        cell.buyImageView.backgroundColor = .lightGray
        cell.buyImageView?.layer.cornerRadius = 10
        cell.buyImageView.contentMode = .scaleAspectFill
        
        cell.upperLabel.text = item.upperString
        cell.upperLabel.backgroundColor = .clear
        cell.upperLabel.font = UIFont(name: "Helvetica", size: 15)!
        cell.upperLabel.textColor = .lightGray
        cell.lowerLabel.text = item.lowerString
        cell.lowerLabel.backgroundColor = .clear
        cell.lowerLabel.font = UIFont(name: "Helvetica", size: 15)!
        cell.lowerLabel.textColor = .lightGray
        
        cell.titleLabel.text = item.title
        cell.titleLabel.textColor = .white
        cell.titleLabel.font = UIFont(name: "Helvetica", size: 15)!
        
        cell.arrowLabel.text = ""
        cell.arrowLabel.textColor = .white
        cell.arrowLabel.backgroundColor = .clear
        
        cell.detailsButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)!
        cell.detailsButton.setTitle("?", for: .normal)
        cell.detailsButton.setTitleColor(.lightGray, for: .normal)
        cell.detailsButton.layer.cornerRadius = 20
        cell.detailsButton.backgroundColor = .clear
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
        guard let fireAuctionItem = viewModel.getFireAuctionItem(at: indexPath.item) else {
            print("[AuctionListViewController][didSelectRowAt] item not available at \(indexPath).")
            return
        }
        GlobalUITask.showSpinner(viewController: self)
        let workGroup = DispatchGroup()
        var imageUrlCoupleList: [ImageUrlCouple] = []
        fireAuctionItem.imagesUrlStringList.forEach {
            guard let url = URL(string: $0) else {
                print("[AuctionListViewController][didSelectRowAt] error at converting url.")
                return
            }
            workGroup.enter()
            viewModel.dataCollector.getImage(urlString: $0) { result in
                switch result {
                case .success(let image):
                    imageUrlCoupleList.append(
                        ImageUrlCouple(image: image, url: url, isFromCloud: true)
                    )
                case .failure(let error):
                    print("[AuctionListViewController][didSelectRowAt] error at fetching image \(error).")
                }
                workGroup.leave()
            }
        }
        
        workGroup.notify(queue: DispatchQueue.main, execute: { [weak self] in
            var viewType = SellDetailsViewType.forBid
            switch self?.viewModel.auctionListViewType {
            case .createdView:
                viewType = .forModify
            default:
                viewType = .forBid
            }
            DispatchQueue.main.async {
                let vc = SellDetailsViewController.makeViewController(
                    viewType: viewType,
                    imageUrlCoupleList: imageUrlCoupleList,
                    fireAuctionItem: fireAuctionItem
                )
                GlobalUITask.removeSpinner(viewController: self ?? UIViewController())
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch viewModel.auctionListViewType {
        case .bidListView:
            return 30
        case .createdView:
            return 30
        case .auctionListView:
            return CGFloat.leastNormalMagnitude
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch viewModel.auctionListViewType {
        case .bidListView:
            let view = UIView()
            view.backgroundColor = color.groundLevelColor
            return view
        case .createdView:
            let view = UIView()
            view.backgroundColor = color.groundLevelColor
            return view
        case .auctionListView:
            let view = UIView()
            view.backgroundColor = color.groundLevelColor
            return view
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        30
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = color.groundLevelColor
        return view
    }
}

extension AuctionListViewController {
    private func prepareHeaderView() {
        guard viewModel.shouldShowHeaderView else {
            headerHeight = 0
            return
        }
        let searchButtonHeight: CGFloat = 35
        let searchViewHeight: CGFloat = 35
        let buttonSize: CGFloat = 35
        let buttonInset: CGFloat = 10
        let textViewEdgeInset: CGFloat = 7.5
        let maxMinSearchViewHeight: CGFloat = 35
        let maxMinSearchViewWidth: CGFloat = (selfWidth - (3 * buttonInset)) / 2
        
        let headerView = UIView()
        headerView.backgroundColor = color.groundLevelColor
        self.view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: headerHeight),
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        
        // Left right page button
        let leftButton = UIButton(type: .system)
        leftButton.frame = CGRect(
            x: buttonInset,
            y: headerHeight - buttonSize - buttonInset,
            width: buttonSize,
            height: buttonSize
        )
        leftButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)!
        leftButton.setTitle("<", for: .normal)
        leftButton.backgroundColor = .clear
        leftButton.setTitleColor(.white, for: .normal)
        leftButton.addTarget(
            self,
            action: #selector(leftArrowButtonAction),
            for: .touchUpInside
        )
        headerView.addSubview(leftButton)
        
        let rightButton = UIButton(type: .system)
        rightButton.frame = CGRect(
            x: selfWidth - buttonSize - buttonInset,
            y: headerHeight - buttonSize - buttonInset,
            width: buttonSize,
            height: buttonSize
        )
        rightButton.titleLabel?.font = UIFont(name: "Helvetica", size: 30)!
        rightButton.setTitle(">", for: .normal)
        rightButton.backgroundColor = .clear
        rightButton.setTitleColor(.white, for: .normal)
        rightButton.addTarget(
            self,
            action: #selector(rightArrowButtonAction),
            for: .touchUpInside
        )
        headerView.addSubview(rightButton)
        
        // page number label
        pageNumLabel.backgroundColor = .clear
        pageNumLabel.textColor = .white
        pageNumLabel.text = "\(viewModel.pageNum)"
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
        searchButton.backgroundColor = color.firstLevelColor
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
        searchView.backgroundColor = color.secondLevelColor
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
        leftSearchView.backgroundColor = color.secondLevelColor
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
        rightSearchView.backgroundColor = color.secondLevelColor
        headerView.addSubview(rightSearchView)
    }
    
    @objc private func searchButtonAction() {
        viewModel.pageNum = 1
        pageNumLabel.text = "\(viewModel.pageNum)"
        viewModel.searchSellItems(
            minimumValue: leftSearchView.text,
            maximumValue: rightSearchView.text,
            searchKeyStr: searchView.text,
            serachKeyTextColor: searchView.textColor ?? .lightGray
        )
        tableView.reloadData()
    }
    
    @objc private func leftArrowButtonAction() {
        var curNum = viewModel.pageNum
        if curNum > 1 {
            curNum = curNum - 1
        }
        viewModel.pageNum = curNum
        pageNumLabel.text = "\(viewModel.pageNum)"
        viewModel.searchSellItems(
            minimumValue: leftSearchView.text,
            maximumValue: rightSearchView.text,
            searchKeyStr: searchView.text,
            serachKeyTextColor: searchView.textColor ?? .lightGray
        )
        tableView.reloadData()
    }
    
    @objc private func rightArrowButtonAction() {
        var curNum = viewModel.pageNum
        curNum = curNum + 1
        viewModel.pageNum = curNum
        pageNumLabel.text = "\(viewModel.pageNum)"
        viewModel.searchSellItems(
            minimumValue: leftSearchView.text,
            maximumValue: rightSearchView.text,
            searchKeyStr: searchView.text,
            serachKeyTextColor: searchView.textColor ?? .lightGray
        )
        tableView.reloadData()
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
            textView.textColor = UIColor.white
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if isEmpty(string: textView.text) {
            textView.text = placeHolderString
            textView.textColor = UIColor.lightGray
        }
    }
}

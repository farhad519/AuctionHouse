//
//  ChatViewController.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 22/1/22.
//

import ReactiveSwift
import UIKit

class ChatViewController: UIViewController {
    private let typingViewContainerHeight: CGFloat = 50
    private var upperExtraHeight: CGFloat = 0
    private var selfWidth: CGFloat = 0
    private var selfHeight: CGFloat = 0
    
    private let color = CustomColor(colorSpectrumValue: Int.random(in: CustomColor.colorRange)).value
    
    private var containerView = UIView()
    private let myTextView = UITextView()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let downButton = UIButton(type: .system)
    private var viewModel: ChatMessangerViewModel!
    private let disposables = CompositeDisposable()
    
    private let myMessageCellId = "MyMessageCollectionViewCell"
    private let otherMessageCellId = "OtherMessageCollectionViewCell"
    private let dateCellId = "DateCollectionViewCell"
    
    static func makeViewController(toId: String) -> ChatViewController {
        let vc = ChatViewController()
        vc.viewModel = ChatMessangerViewModel(toId: toId)
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.showsVerticalScrollIndicator = false
        
        selfWidth = self.view.frame.width
        selfHeight = self.view.frame.height
        upperExtraHeight = (navigationController?.navigationBar.frame.height ?? 0) + (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        
        setupCollectionView()
        setupContainerView()
        setupTypingView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        disposables += viewModel.observeOutputSignal.startWithValues { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.reloadData()
            if self.viewModel.shouldScrollToFirst {
                self.viewModel.setLastScrollTime()
                let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
                let lastItemIndex = IndexPath(item: item, section: 0)
                self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
            }
        }
        disposables += viewModel.fetchData()
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.backgroundColor = color.groundLevelColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        disposables.dispose()
    }
    
    private func setupCollectionView() {
        collectionView.frame = CGRect(
            x: 0,
            y: upperExtraHeight,
            width: selfWidth,
            height: selfHeight - typingViewContainerHeight - upperExtraHeight
        )
        collectionView.backgroundColor = color.groundLevelColor
        containerView.addSubview(collectionView)
        
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let cellSize = CGSize(width: 0, height: 0)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 1.0
        collectionView.setCollectionViewLayout(layout, animated: true)
        
        
        let bundle = Bundle(for: type(of: self))
        collectionView.register(
            UINib(nibName: myMessageCellId, bundle: bundle),
            forCellWithReuseIdentifier: myMessageCellId
        )
        collectionView.register(
            UINib(nibName: otherMessageCellId, bundle: bundle),
            forCellWithReuseIdentifier: otherMessageCellId
        )
        collectionView.register(
            UINib(nibName: dateCellId, bundle: bundle),
            forCellWithReuseIdentifier: dateCellId
        )
    }
    
    private func setupContainerView() {
        containerView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: selfHeight)
        containerView.backgroundColor = color.groundLevelColor
        self.view.addSubview(containerView)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        print("keyboard will appear.")
        downButton.isHidden = false
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            print("[ChatViewController][keyboardWillAppear] no height for keyboard")
            return
        }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        containerView.frame = CGRect(x: 0, y: -keyboardHeight, width: selfWidth, height: selfHeight)
        collectionView.contentInset.top = keyboardHeight
    }

    @objc func keyboardWillDisappear(_ notification: Notification) {
        print("keyboard will disappear.")
        downButton.isHidden = true
        containerView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: selfHeight)
        collectionView.contentInset.top = 0
    }
    
    @objc private func sendButtonAction(sender: UIButton) {
        guard viewModel.isOnlySpaceAndNewLine(text: myTextView.text) == false else { return }
        
        viewModel.saveMyMessage(message: myTextView.text)
    }
    
    @objc private func downButtonAction(sender: UIButton) {
        view.endEditing(true)
    }
    
    private func setupTypingView() {
        let itemInsetSpace: CGFloat = 5
        
        let typingContainer = UIView()
        typingContainer.frame = CGRect(
            x: 0,
            y: selfHeight - typingViewContainerHeight,
            width: selfWidth,
            height: typingViewContainerHeight
        )
        typingContainer.backgroundColor = color.groundLevelColor
        containerView.addSubview(typingContainer)
        
        
        let lineViewHeight: CGFloat = 0.5
        let lineView = UIView()
        lineView.frame = CGRect(
            x: 0,
            y: 0,
            width: selfWidth,
            height: lineViewHeight
        )
        lineView.backgroundColor = color.firstLevelColor
        typingContainer.addSubview(lineView)
        
        
        let sendButtonWidth: CGFloat = 50
        let sendButton = UIButton(type: .system)
        sendButton.frame = CGRect(
            x: selfWidth - (sendButtonWidth + itemInsetSpace),
            y: itemInsetSpace,
            width: sendButtonWidth,
            height: typingViewContainerHeight - (itemInsetSpace * 2)
        )
        sendButton.setTitle("send", for: .normal)
        sendButton.backgroundColor = color.firstLevelColor
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 5
        sendButton.addTarget(
            self,
            action: #selector(sendButtonAction),
            for: .touchUpInside
        )
        typingContainer.addSubview(sendButton)
        
        
        let downButtonWidth: CGFloat = 20
        downButton.frame = CGRect(
            x: itemInsetSpace,
            y: itemInsetSpace,
            width: downButtonWidth,
            height: typingViewContainerHeight - (itemInsetSpace * 2)
        )
        downButton.backgroundColor = color.firstLevelColor
        downButton.setTitle("V", for: .normal)
        downButton.setTitleColor(.white, for: .normal)
        downButton.layer.cornerRadius = 5
        downButton.isHidden = true
        downButton.addTarget(
            self,
            action: #selector(downButtonAction),
            for: .touchUpInside
        )
        typingContainer.addSubview(downButton)
        
        
        myTextView.frame = CGRect(
            x: downButtonWidth + (itemInsetSpace * 2),
            y: itemInsetSpace,
            width: selfWidth - (itemInsetSpace * 4) - (sendButtonWidth + downButtonWidth),
            height: typingViewContainerHeight - (itemInsetSpace * 2)
        )
        myTextView.backgroundColor = color.firstLevelColor
        myTextView.textColor = .white
        myTextView.layer.cornerRadius = 5
        myTextView.font = .systemFont(ofSize: 19)
        typingContainer.addSubview(myTextView)
    }
    
}

extension ChatViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messageList.count * 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < viewModel.messageList.count * 2 else {
            print("[ChatViewController][cellForItemAt] no data for indexPath = \(indexPath)")
            return UICollectionViewCell()
        }
        
        let newIndexItem: Int = indexPath.item  / 2
        let messageData = viewModel.messageList[newIndexItem]
        
        guard indexPath.item % 2 == 1 else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dateCellId, for: indexPath) as? DateCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(truncating: messageData.timeStamp))
            let dateFormatter = DateFormatter()
            
            if Calendar.current.isDateInToday(date) {
                dateFormatter.dateFormat = "hh:mm a"
            } else {
                dateFormatter.dateFormat = "yyyy-MM-dd"
            }
            
            cell.dateLabel.font = .systemFont(ofSize: 8)
            cell.dateLabel.text = dateFormatter.string(from: date as Date)
            cell.dateLabel.textColor = .white
            //cell.dateLabel.text = ""
            return cell
        }
        
        if messageData.isMyMessage {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myMessageCellId, for: indexPath) as? MyMessageCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let textViewWidth = viewModel.getTextWidth(text: messageData.message, font: viewModel.font)
            var leftSpace = selfWidth - (textViewWidth + (viewModel.textViewInsetSpace * 2) + viewModel.myMessageCellRightInset)
            if viewModel.otherMessageCellLeftSpace > leftSpace {
                leftSpace = viewModel.otherMessageCellLeftSpace
            }
            
            cell.setupCell(
                message: messageData.message,
                font: viewModel.font,
                color: color.firstLevelColor,
                insetSize: viewModel.textViewInsetSpace,
                leftSpace: leftSpace,
                oneLineSize: viewModel.oneLineHeight(),
                trailingInset: viewModel.myMessageCellRightInset
            )

            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: otherMessageCellId, for: indexPath) as? OtherMessageCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            let textViewWidth = viewModel.getTextWidth(text: messageData.message, font: viewModel.font)
            var rightSpace = selfWidth - (viewModel.oneLineHeight() + 5 + textViewWidth + (viewModel.textViewInsetSpace * 2) + viewModel.myMessageCellRightInset)
            if viewModel.otherMessageCellLeftSpace > rightSpace {
                rightSpace = viewModel.otherMessageCellLeftSpace
            }
            
            cell.setupCell(
                email: viewModel.email,
                message: messageData.message,
                image: UIImage(),
                font: viewModel.font,
                color: color.secondLevelColor,
                imageSize: viewModel.oneLineHeight(),
                insetSize: viewModel.textViewInsetSpace,
                rightSpace: rightSpace,
                leadingInset: viewModel.myMessageCellRightInset
            )

            return cell
        }
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < viewModel.messageList.count * 2 else {
            print("[ChatViewController][sizeForItemAt] no data for indexPath = \(indexPath)")
            return .zero
        }
        
        let newIndexItem: Int = indexPath.item / 2
        let messageData = viewModel.messageList[newIndexItem]
        
        guard indexPath.item % 2 == 1 else {
            return CGSize(width: selfWidth, height: 12)
        }
        
        if messageData.isMyMessage {
            let height = viewModel.getTextHeight(
                stringVal: messageData.message,
                width: selfWidth - (viewModel.otherMessageCellLeftSpace + (viewModel.textViewInsetSpace * 2) + viewModel.myMessageCellRightInset)
            ) + (viewModel.textViewInsetSpace * 2)
            
            return CGSize(width: selfWidth, height: height)
        } else {
            let height = viewModel.getTextHeight(
                stringVal: messageData.message,
                width: selfWidth - (viewModel.otherMessageCellLeftSpace + viewModel.oneLineHeight() + 5 + (viewModel.textViewInsetSpace * 2) + viewModel.myMessageCellRightInset)
            ) + (viewModel.textViewInsetSpace * 2)
            
            return CGSize(width: selfWidth, height: height)
        }
    }
}

extension ChatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

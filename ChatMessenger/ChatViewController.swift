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
    
    private var containerView = UIView()
    private let myTextView = UITextView()
    private var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private var viewModel: ChatMessangerViewModel!
    private let disposables = CompositeDisposable()
    
    private let myMessageCellId = "MyMessageCollectionViewCell"
    private let otherMessageCellId = "OtherMessageCollectionViewCell"
    
    static func makeViewController() -> ChatViewController {
        let vc = ChatViewController()
        vc.viewModel = ChatMessangerViewModel(toId: "")
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        disposables += viewModel.observeOutputSignal.startWithValues { [weak self] _ in
            self?.collectionView.reloadData()
        }
        disposables += viewModel.fetchData()
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
        //collectionView.backgroundColor = .green
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
    }
    
    private func setupContainerView() {
        containerView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: selfHeight)
        containerView.backgroundColor = .white
        self.view.addSubview(containerView)
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        print("keyboard will appear.")
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
        containerView.frame = CGRect(x: 0, y: 0, width: selfWidth, height: selfHeight)
        collectionView.contentInset.top = 0
    }
    
    @objc private func sendButtonAction(sender: UIButton) {
        guard viewModel.isOnlySpaceAndNewLine(text: myTextView.text) == false else { return }
        
        viewModel.saveMyMessage(message: myTextView.text)
        
        let item = collectionView(collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
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
        typingContainer.backgroundColor = .white
        containerView.addSubview(typingContainer)
        
        
        let lineViewHeight: CGFloat = 0.5
        let lineView = UIView()
        lineView.frame = CGRect(
            x: 0,
            y: 0,
            width: selfWidth,
            height: lineViewHeight
        )
        lineView.backgroundColor = .black
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
        sendButton.backgroundColor = .white
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.addTarget(
            self,
            action: #selector(sendButtonAction),
            for: .touchUpInside
        )
        typingContainer.addSubview(sendButton)
        
        
        let downButtonWidth: CGFloat = 20
        let downButton = UIButton(type: .system)
        downButton.frame = CGRect(
            x: itemInsetSpace,
            y: itemInsetSpace,
            width: downButtonWidth,
            height: typingViewContainerHeight - (itemInsetSpace * 2)
        )
        downButton.backgroundColor = .clear
        downButton.setTitle("V", for: .normal)
        typingContainer.addSubview(downButton)
        
        
        myTextView.frame = CGRect(
            x: downButtonWidth + (itemInsetSpace * 2),
            y: itemInsetSpace,
            width: selfWidth - (itemInsetSpace * 4) - (sendButtonWidth + downButtonWidth),
            height: typingViewContainerHeight - (itemInsetSpace * 2)
        )
        myTextView.backgroundColor = .lightGray
        typingContainer.addSubview(myTextView)
    }
    
}

extension ChatViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.item < viewModel.messageList.count else {
            print("[ChatViewController][cellForItemAt] no data for indexPath = \(indexPath)")
            return UICollectionViewCell()
        }
        
        let messageData = viewModel.messageList[indexPath.item]
        
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
            var rightSpace = selfWidth - (viewModel.oneLineHeight() + 1 + textViewWidth + (viewModel.textViewInsetSpace * 2))
            if viewModel.otherMessageCellLeftSpace > rightSpace {
                rightSpace = viewModel.otherMessageCellLeftSpace
            }
            
            cell.setupCell(
                message: messageData.message,
                image: UIImage(named: "img1") ?? UIImage(),
                font: viewModel.font,
                imageSize: viewModel.oneLineHeight(),
                insetSize: viewModel.textViewInsetSpace,
                rightSpace: rightSpace
            )

            return cell
        }
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.item < viewModel.messageList.count else {
            print("[ChatViewController][sizeForItemAt] no data for indexPath = \(indexPath)")
            return .zero
        }
        
        let messageData = viewModel.messageList[indexPath.item]
        
        if messageData.isMyMessage {
            let height = viewModel.getTextHeight(
                stringVal: messageData.message,
                width: selfWidth - (viewModel.otherMessageCellLeftSpace + (viewModel.textViewInsetSpace * 2) + viewModel.myMessageCellRightInset)
            ) + (viewModel.textViewInsetSpace * 2)
            
            return CGSize(width: selfWidth, height: height)
        } else {
            let height = viewModel.getTextHeight(
                stringVal: messageData.message,
                width: selfWidth - (viewModel.otherMessageCellLeftSpace + viewModel.oneLineHeight() + 1 + (viewModel.textViewInsetSpace * 2))
            ) + (viewModel.textViewInsetSpace * 2)
            
            return CGSize(width: selfWidth, height: height)
        }
    }
}

extension ChatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

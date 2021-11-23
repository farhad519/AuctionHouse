//
//  ChatMesengerViewController.swift
//  AuctionHouse
//
//  Created by Mohammod Ullah Chowdhury on 23/8/21.
//

import UIKit

class ChatMesengerViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let messageViewContainer = UIView()
    private let sendTextView = UITextView()
    private let okButton = UIButton()
    private let downButton = UIButton()
    
    private var selfWidth: CGFloat = 0
    private var selfHeight: CGFloat = 0
    private var keyBoardHeight: CGFloat = 0
    private let dateViewHeight: CGFloat = 30
    
    private var textList: [String] = []
    
    static func makeViewController() -> ChatMesengerViewController {
        let vc = ChatMesengerViewController()
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfWidth = self.view.frame.width
        selfHeight = self.view.frame.height
        self.view.backgroundColor = .blue
        //scrollViewSetup()
        messageViewSetup(textView: sendTextView)
        
//        let vvv = configureRecievedMessageView(
//            stringVal: "aaaaaaaaaaaaaaaaaaaaaaabb\nc",
//            image: UIImage(named: "img1")!
//        )
//        scrollView.addSubview(vvv)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        //getTextWidth(text: "as as\nasd", font: UIFont(name: "Helvetica", size: 19)!)
        //addDateText(text: getFormattedDate(), usedHeight: 0)
    }
    
    @objc private func keyboardWillShow(_ notification : Notification?) -> Void {
        var kbSize: CGSize = .zero
        
        if let info = notification?.userInfo {
            let frameEndUserInfoKey = UIResponder.keyboardFrameEndUserInfoKey
            
            //  Getting UIKeyboardSize.
            if let kbFrame = info[frameEndUserInfoKey] as? CGRect {
                let screenSize = UIScreen.main.bounds
                
                //Calculating actual keyboard displayed size, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381)
                let intersectRect = kbFrame.intersection(screenSize)
                
                if intersectRect.isNull {
                    kbSize = CGSize(width: screenSize.size.width, height: 0)
                } else {
                    kbSize = intersectRect.size
                }
                print("Your Keyboard Size \(kbSize)")
                
                keyBoardHeight = kbSize.height
                adjustMessageView(textView: sendTextView)
            }
        }
    }
    
    private  func updateScrollViewText() {
        scrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        let reversedList = textList.reversed()
        
        var neededHeight: CGFloat = 0
        let (_, getContainerHeight) = addSentMessageText(text: "", usedHeight: 0, isFuncOnly: true)
        //let (_, getContainerHeight) = addRecievedMessageText(text: "", image: UIImage(named: "img1")!, usedHeight: 0, isFuncOnly: true)
        for stringVal in reversedList {
            neededHeight = neededHeight + getContainerHeight(stringVal)
        }
        
        if scrollView.contentSize.height < neededHeight {
            scrollView.contentSize = CGSize(width: selfWidth, height: CGFloat.maximum(neededHeight, 1000))
        }
        
        var usedHeight: CGFloat = 0
        for stringVal in reversedList {
            let (height, _) = addSentMessageText(text: stringVal, usedHeight: usedHeight, isFuncOnly: false)
            //let (height, _) = addRecievedMessageText(text: stringVal, image: UIImage(named: "img1")!, usedHeight: usedHeight, isFuncOnly: false)
            usedHeight = usedHeight + height
            //addDateText(text: getFormattedDate(), usedHeight: usedHeight)
            //usedHeight = usedHeight + dateViewHeight
        }
    }
    
    private func addDateText(
        text: String,
        usedHeight: CGFloat
    ) {
        let insetSpace: CGFloat = 5
        let textFont: UIFont = .systemFont(ofSize: 12)
        
        let containerView = UIView()
        let textLael = UILabel()
        textLael.frame = CGRect(
            x: insetSpace,
            y: insetSpace,
            width: selfWidth - (2 * insetSpace),
            height: dateViewHeight - (2 * insetSpace)
        )
        textLael.font = textFont
        textLael.textAlignment = .center
        textLael.text = text
        containerView.addSubview(textLael)
        
        let scrollViewContentHeight = scrollView.contentSize.height
        containerView.backgroundColor = .yellow
        containerView.frame = CGRect(
            x: 0,
            y: scrollViewContentHeight - dateViewHeight - usedHeight,
            width: selfWidth,
            height: dateViewHeight
        )
        
        scrollView.addSubview(containerView)
        scrollView.setContentOffset(
            CGPoint(
                x: 0,
                y: scrollViewContentHeight - selfHeight + messageViewContainer.frame.height + keyBoardHeight
            ),
            animated: false
        )
    }
    
    private func addRecievedMessageText(
        text: String,
        image: UIImage,
        usedHeight: CGFloat, isFuncOnly: Bool
    ) -> (CGFloat, (String) -> CGFloat ) {
//        if let font = UIFont(name: "Helvetica", size: 19) {
//            let fontAttributes = [NSAttributedString.Key.font: font]
//            let myText = "A"
//            let size = (myText as NSString).size(withAttributes: fontAttributes)
//            print(size)
//        }
//        var vvvv: CGFloat = 0
//        for c in stringVal {
//            if let font = UIFont(name: "Helvetica", size: 19) {
//                let fontAttributes = [NSAttributedString.Key.font: font]
//                let myText = "\(c)"
//                let size = (myText as NSString).size(withAttributes: fontAttributes)
//                vvvv = vvvv + size.width
//            }
//        }
        
        let viewContainer = UIView()
    
        let internalSpace: CGFloat = 5
        let insetSpace: CGFloat = 5
        let rightSpace: CGFloat = 40
        let textEdgeInset: CGFloat = 5
        
        let textViewFont: UIFont = UIFont(name: "Helvetica", size: 19)!
        // height one line of text size
        let imageViewSize: CGFloat = getTextHeight(
            stringVal: "a",
            font: textViewFont,
            width: 20 // any width that covers stringVal
        ) + (2 * textEdgeInset)
        let containerWidth: CGFloat = selfWidth
        let availableOnlyTextWidth: CGFloat = containerWidth - (insetSpace + internalSpace + imageViewSize + insetSpace + rightSpace - textEdgeInset - textEdgeInset)
        
        let textRealWidth = getTextWidth(text: text, font: textViewFont)
        var reducedTextWidth: CGFloat = availableOnlyTextWidth
        if textRealWidth < availableOnlyTextWidth {
            reducedTextWidth = textRealWidth
        }
        
        func getContainerHeight(text: String) -> CGFloat {
            getTextHeight(
                stringVal: text,
                font: textViewFont,
                width: reducedTextWidth
            ) + insetSpace + insetSpace + (2 * textEdgeInset)
        }
        
        guard isFuncOnly == false else {
            return (0, getContainerHeight)
        }
        
        let containerHeight: CGFloat = getContainerHeight(text: text)
        
        let imageView = UIImageView()
        imageView.frame = CGRect(
            x: insetSpace,
            y: containerHeight - insetSpace - imageViewSize,
            width: imageViewSize,
            height: imageViewSize
        )
        imageView.image = image
        imageView.layer.cornerRadius = imageViewSize / 2
        imageView.clipsToBounds = true
        //imageView.layer.masksToBounds = false
        viewContainer.addSubview(imageView)
        
        let textView = UITextView()
        textView.frame = CGRect(
            x: insetSpace + internalSpace + imageViewSize,
            y: insetSpace,
            width: reducedTextWidth + (2 * textEdgeInset),
            height: containerHeight - (insetSpace + insetSpace)
        )
        textView.text = text
        textView.isEditable = false
        textView.layer.cornerRadius = imageViewSize / 2
        textView.backgroundColor = UIColor(hex: "#ededed", alpha: 1)
        textView.font = textViewFont
        //textView.textContainer.lineFragmentPadding = 0
        //textView.textContainerInset = .zero
        textView.textContainerInset = UIEdgeInsets(top: textEdgeInset, left: textEdgeInset, bottom: textEdgeInset, right: textEdgeInset)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        viewContainer.addSubview(textView)
        
        let scrollViewContentHeight = scrollView.contentSize.height
        viewContainer.backgroundColor = .green
        viewContainer.frame = CGRect(
            x: 0,
            y: scrollViewContentHeight - containerHeight - usedHeight,
            width: containerWidth,
            height: containerHeight
        )
        
        scrollView.addSubview(viewContainer)
        scrollView.setContentOffset(
            CGPoint(x: 0, y: scrollViewContentHeight - selfHeight + messageViewContainer.frame.height + keyBoardHeight),
            animated: false
        )
        
        return (containerHeight, getContainerHeight)
    }
    
    private func addSentMessageText(text: String, usedHeight: CGFloat, isFuncOnly: Bool) -> (CGFloat, (String) -> CGFloat ) {
        let leftSpace:CGFloat = 40
        let insetSpace: CGFloat = 5
        let textEdgeInset: CGFloat = 5
        let sentTextContainer = UIView()
        let sentMessageTextView = UITextView()
        let textViewFont: UIFont = UIFont(name: "Helvetica", size: 19)!
        let availableOnlyTextWidth: CGFloat = selfWidth - (2 * insetSpace) - (2 * textEdgeInset) - leftSpace
        
        let textRealWidth = getTextWidth(text: text, font: textViewFont)
        var reducedTextWidth: CGFloat = availableOnlyTextWidth
        if textRealWidth < availableOnlyTextWidth {
            reducedTextWidth = textRealWidth
        }
        
        func getContainerHeight(text: String) -> CGFloat {
            getTextHeight(
                stringVal: text,
                font: textViewFont,
                width: reducedTextWidth
            ) + (2 * insetSpace) + (2 * textEdgeInset)
        }
        
        guard isFuncOnly == false else {
            return (0.0, getContainerHeight)
        }
        
        let containerHeight = getContainerHeight(text: text)
        sentMessageTextView.frame = CGRect(
            x: selfWidth - insetSpace - reducedTextWidth - (2 * textEdgeInset),
            y: insetSpace,
            width: reducedTextWidth + (2 * textEdgeInset),
            height: containerHeight - (2 * insetSpace)
        )
        sentMessageTextView.textContainerInset = UIEdgeInsets(top: textEdgeInset, left: textEdgeInset, bottom: textEdgeInset, right: textEdgeInset)
        sentMessageTextView.textContainer.lineFragmentPadding = 0
        sentMessageTextView.isEditable = false
        sentMessageTextView.text = text
        sentMessageTextView.font = textViewFont
        sentMessageTextView.backgroundColor = UIColor(hex: "#ededed", alpha: 1)
        sentMessageTextView.layer.cornerRadius = 10
        sentMessageTextView.isScrollEnabled = false
        sentTextContainer.addSubview(sentMessageTextView)
        
//        if scrollView.contentSize.height < (containerHeight + usedHeight) {
//            scrollView.contentSize = CGSize(width: selfWidth, height: containerHeight + usedHeight)
//        }
        let scrollViewContentHeight = scrollView.contentSize.height
        sentTextContainer.frame = CGRect(
            x: 0,
            y: scrollViewContentHeight - containerHeight - usedHeight,
            width: selfWidth,
            height: containerHeight
        )
        scrollView.addSubview(sentTextContainer)
        scrollView.setContentOffset(
            CGPoint(x: 0, y: scrollViewContentHeight - selfHeight + messageViewContainer.frame.height + keyBoardHeight),
            animated: false
        )
        
        return (containerHeight, getContainerHeight)
    }
    
    @objc private func tappedOnOkButton(sender: UIButton) {
        print("ok")
//        UIView.animate(
//            withDuration: 0.3,
//            animations: {
//                self.sendTextView.resignFirstResponder()
//            },
//            completion: { _ in
//                //if self.sendTextView.text == "" { return }
//                self.keyBoardHeight = 0
//                self.textList.append(self.sendTextView.text)
//                self.sendTextView.text = ""
//                self.adjustMessageView(textView: self.sendTextView)
//                self.updateScrollViewText()
//            }
//        )
        guard isOnlySpaceAndNewLine(text: sendTextView.text) == false else {
            return
        }
        textList.append(sendTextView.text)
        sendTextView.text = ""
        adjustMessageView(textView: sendTextView)
        updateScrollViewText()
    }
    
    @objc private func tappedOnDownButton(sender: UIButton) {
        print("down")
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.sendTextView.resignFirstResponder()
            },
            completion: { _ in
                self.keyBoardHeight = 0
                self.adjustMessageView(textView: self.sendTextView)
                self.updateScrollViewText()
            }
        )
    }
    
    private func messageViewSetup(textView: UITextView) {
        // scrollView setUp
        self.view.addSubview(scrollView)
        scrollView.backgroundColor = .white
        scrollView.contentSize = CGSize(
            width: selfWidth,
            height: 1000
        )
        
        // messageContainerView setup
        messageViewContainer.backgroundColor = .white
        
        textView.backgroundColor = UIColor(hex: "#ededed", alpha: 1)
        textView.delegate = self
        //textView.isScrollEnabled = false
        
        okButton.backgroundColor = .orange
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(.black, for: .normal)
        okButton.setTitleColor(.gray, for: .highlighted)
        okButton.backgroundColor = .clear
        okButton.addTarget(
            self,
            action: #selector(tappedOnOkButton),
            for: .touchUpInside
        )
        
        downButton.backgroundColor = .orange
        downButton.setTitle("DO", for: .normal)
        downButton.setTitleColor(.black, for: .normal)
        downButton.setTitleColor(.gray, for: .highlighted)
        downButton.backgroundColor = .clear
        downButton.addTarget(
            self,
            action: #selector(tappedOnDownButton),
            for: .touchUpInside
        )
        
        self.view.addSubview(messageViewContainer)
        messageViewContainer.addSubview(textView)
        messageViewContainer.addSubview(okButton)
        messageViewContainer.addSubview(downButton)
        adjustMessageView(textView: textView)
    }
    
    private func adjustMessageView(textView: UITextView) {
        let buttonSize: CGFloat = 30
        
        let insetSpace: CGFloat = 5
        let textEdgeInset: CGFloat = 5
        
        let textViewFont: UIFont = .systemFont(ofSize: 19)
        let availableOnlyTextWidth: CGFloat = selfWidth - (2 * textEdgeInset) - (2 * insetSpace) - buttonSize - buttonSize - (2 * insetSpace)
        func getContainerHeight(text: String) -> CGFloat {
            getTextHeight(
                stringVal: text,
                font: textViewFont,
                width: availableOnlyTextWidth
            ) + (2 * insetSpace) + (2 * textEdgeInset)
        }
        
        let oneLinerHeight = getContainerHeight(text: "Aa")
        let fourLinerHeight = getContainerHeight(text: "Aa\n\n\n\n\n")
        var containerHeight: CGFloat = getContainerHeight(text: textView.text)
        
        if containerHeight < oneLinerHeight || keyBoardHeight == 0.0 {
            containerHeight = oneLinerHeight
        } else if containerHeight > fourLinerHeight {
            containerHeight = fourLinerHeight
        }
        
        textView.frame = CGRect(
            x: insetSpace + insetSpace + buttonSize,
            y: insetSpace,
            width: selfWidth - (2 * insetSpace) - buttonSize - buttonSize - insetSpace,
            height: containerHeight - (2 * insetSpace)
        )
        textView.textContainerInset = UIEdgeInsets(top: textEdgeInset, left: textEdgeInset, bottom: textEdgeInset, right: textEdgeInset)
        textView.layer.cornerRadius = 10
        //textView.text = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        textView.font = textViewFont
        
        messageViewContainer.frame = CGRect(
            x: 0,
            y: selfHeight - containerHeight - keyBoardHeight,
            width: selfWidth,
            height: containerHeight
        )
        
        scrollView.frame = CGRect(
            x: 0,
            y: 0,
            width: selfWidth,
            height: selfHeight - containerHeight
        )
        scrollView.setContentOffset(
            CGPoint(x: 0, y: scrollView.contentSize.height - selfHeight + containerHeight + keyBoardHeight),
            animated: false
        )
        
        okButton.frame = CGRect(
            x: selfWidth - insetSpace - buttonSize,
            y: containerHeight - insetSpace - buttonSize,
            width: buttonSize,
            height: buttonSize
        )
        
        downButton.frame = CGRect(
            x: insetSpace,
            y: containerHeight - insetSpace - buttonSize,
            width: buttonSize,
            height: buttonSize
        )
        
        if keyBoardHeight == 0.0 {
            okButton.isHidden = true
            downButton.isHidden = true
        } else {
            okButton.isHidden = false
            downButton.isHidden = false
        }
    }
    
    private func isOnlySpaceAndNewLine(text: String) -> Bool {
        for c in text {
            if c != " " && c != "\n" {
                return false
            }
        }
        return true
    }
    
    private func getTextWidth(text: String, font: UIFont) -> CGFloat {
        var width: CGFloat = 0
        var maxWidth: CGFloat = 0
        for c in text {
            if c == "\n" {
                maxWidth = CGFloat.maximum(width, maxWidth)
                width = 0
                continue
            }
            let fontAttributes = [NSAttributedString.Key.font: font]
            let myText = "\(c)"
            let size = (myText as NSString).size(withAttributes: fontAttributes)
            width = width + size.width
        }
        maxWidth = CGFloat.maximum(width, maxWidth)
        return maxWidth
    }
    
    private func getFormattedDate() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let dateText = formatter.string(from: currentDateTime)
        
        formatter.dateFormat = "HH:mm"
        let timeText = formatter.string(from: currentDateTime)

        return "\(dateText) AT \(timeText)".uppercased()
    }
    
    private func getTextHeight(stringVal: String, font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = stringVal.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        return boundingBox.height
    }
}

extension ChatMesengerViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
//        let frame = textView.frame
//        textView.frame = CGRect(
//            x: frame.minX,
//            y: frame.minY - 10,
//            width: frame.width,
//            height: frame.height + 10
//        )
        adjustMessageView(textView: textView)
        print(textView.text)
    }
}

class TextField: UITextField {
    let padding = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

//testTextLabel.translatesAutoresizingMaskIntoConstraints = false
//NSLayoutConstraint.activate([
//    testTextLabel.topAnchor.constraint(equalTo: testTextLabel.superview!.safeAreaLayoutGuide.topAnchor, constant: 12),
//    testTextLabel.leadingAnchor.constraint(equalTo: testTextLabel.superview!.leadingAnchor, constant:  12),
//    testTextLabel.widthAnchor.constraint(equalToConstant: 250),
//    testTextLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 70)
//])


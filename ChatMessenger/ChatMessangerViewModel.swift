//
//  ChatMessangerViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 19/1/22.
//

import Foundation
import ReactiveSwift

struct MessageModel {
    var message: String
    var timeStamp: NSNumber
    var isMyMessage: Bool
}

class ChatMessangerViewModel {
    enum EventUI {
        case reloadData
    }
    //private var messageItemList: [FireMessageItem] = []
    private let (observeOutput, sendInput) = Signal<EventUI, Never>.pipe()
    private var shouldFetchAgain: Bool = true
    var messageList: [MessageModel] = [] {
        didSet{ sendInput.send(value: .reloadData) }
    }
    private var myMessageList: [MessageModel] = []
    private var otherMessageList: [MessageModel] = []
    private let dataCollector = DataCollector()
    private let toId: String
    let font: UIFont = .systemFont(ofSize: 19)
    let otherMessageCellLeftSpace: CGFloat = 40
    let textViewInsetSpace: CGFloat = 10
    let myMessageCellRightInset: CGFloat = 5
    var observeOutputSignal: SignalProducer<ChatMessangerViewModel.EventUI, Never> {
        observeOutput.producer
    }
    
    init(toId: String) {
        self.toId = toId
        fetchMyMessageFromFire()
    }
    
    func prepareDummyData() {
        messageList.append(
            MessageModel(
                message: "asdasd",
                timeStamp: NSNumber(value: 12),
                isMyMessage: true
            )
        )
        messageList.append(
            MessageModel(
                message: "asdasd",
                timeStamp: NSNumber(value: 12),
                isMyMessage: true
            )
        )
        messageList.append(
            MessageModel(
                message: "asdasd",
                timeStamp: NSNumber(value: 12),
                isMyMessage: false
            )
        )
        messageList.append(
            MessageModel(
                message: "asdasd",
                timeStamp: NSNumber(value: 12),
                isMyMessage: true
            )
        )
        messageList.append(
            MessageModel(
                message: "asdasd",
                timeStamp: NSNumber(value: 12),
                isMyMessage: false
            )
        )
    }
    
    func fetchData() -> Disposable {
        SignalProducer.timer(interval: .milliseconds(100), on: QueueScheduler()).startWithValues { [weak self] _ in
            guard let self = self else { return }
            guard self.shouldFetchAgain else { return }
            self.shouldFetchAgain = false
            self.dataCollector.getDirectMessages(toId: self.toId).startWithResult { result in
                switch result {
                case .success(let messageItemList):
                    self.prepareData(messageItemList: messageItemList)
                case .failure(let error):
                    print("[ChatMessangerViewModel][fetchData] error at fetching contact data \(error)")
                }
                self.shouldFetchAgain = true
            }
        }
    }
    
    func fetchMyMessageFromFire() {
        dataCollector.getMyDirectMessages(toId: toId) { [weak self] result in
            switch result {
            case .success(let messageItemList):
                self?.myMessageList = messageItemList.map {
                    MessageModel(
                        message: $0.message,
                        timeStamp: $0.timeStamp,
                        isMyMessage: true
                    )
                }
            case .failure(let error):
                print("[ChatMessangerViewModel][fetchMyMessageFromFire] error at fetching contact data \(error)")
            }
        }
    }
    
    private func prepareData(messageItemList: [FireMessageItem]) {
        var otherMessageList = messageItemList.compactMap {
            MessageModel(
                message: $0.message,
                timeStamp: $0.timeStamp,
                isMyMessage: false
            )
        }
        
        otherMessageList.append(contentsOf: myMessageList)
        messageList = otherMessageList.sorted(
            by: { ($0.timeStamp as? Int32 ?? 0) < ($1.timeStamp as? Int32 ?? 0) }
        )
    }
    
    func saveMyMessage(message: String) {
        let messageModel = MessageModel(
            message: message,
            timeStamp: NSNumber(value: Int(NSDate().timeIntervalSince1970)),
            isMyMessage: true
        )
        dataCollector.postDirectMessages(
            message: messageModel.message,
            timeStamp: messageModel.timeStamp,
            toId: toId
        )
        dataCollector.postRecentMessages(
            message: message,
            iconUrl: "",
            toId: toId
        )
        myMessageList.append(messageModel)
    }
    
    func getTextWidth(text: String, font: UIFont) -> CGFloat {
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
    
    func getFormattedDate() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        let dateText = formatter.string(from: currentDateTime)
        
        formatter.dateFormat = "HH:mm"
        let timeText = formatter.string(from: currentDateTime)

        return "\(dateText) AT \(timeText)".uppercased()
    }
    
    func getTextHeight(stringVal: String, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = stringVal.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        
        return boundingBox.height
    }
    
    func oneLineHeight() -> CGFloat {
        getTextHeight(stringVal: "Aa", width: 100)
    }
    
    func isOnlySpaceAndNewLine(text: String) -> Bool {
        for c in text {
            if c != " " && c != "\n" {
                return false
            }
        }
        return true
    }
}

//
//  ContactListViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 14/1/22.
//

import Foundation
import ReactiveSwift

class ContactListViewModel {
    enum EventUI {
        case reloadData
    }
    private let (observeOutput, sendInput) = Signal<EventUI, Never>.pipe()
    var observeForUpdate: SignalProducer<ContactListViewModel.EventUI, Never> {
        observeOutput.producer
    }
    
    var contactList: [FireContactItem] = []
    private var shouldFetchAgain: Bool = true
    private let dataCollector = DataCollector()
    var idVStimeDic: [String: NSNumber] = [:]
    
    init() {
        getLastReadMessages()
    }
    
    func getLastReadMessages() {
        dataCollector.getRecentMessagesLastReadTime().startWithResult { result in
            switch result {
            case .success(let idVStimeDic):
                self.idVStimeDic = idVStimeDic
                self.sendInput.send(value: .reloadData)
            case .failure(let error):
                print("[ContactListViewModel][getLastReadMessages] error at fetching contact data \(error)")
            }
        }
    }
    
    func fetchData() -> Disposable {
        SignalProducer.timer(interval: .milliseconds(100), on: QueueScheduler()).startWithValues { [weak self] _ in
            guard let self = self else { return }
            guard self.shouldFetchAgain else { return }
            self.shouldFetchAgain = false
            self.dataCollector.getRecentMessages().startWithResult { result in
                switch result {
                case .success(let contactItemList):
                    self.contactList = contactItemList
                    self.sendInput.send(value: .reloadData)
                case .failure(let error):
                    print("[ContactListViewModel][fetchData] error at fetching contact data \(error)")
                }
                self.shouldFetchAgain = true
            }
        }
    }
    
    func isRead(for indexPath: IndexPath) -> Bool {
        guard indexPath.item < contactList.count else {
            print("[ContactListViewModel][isRead] isRead out of indexPath at \(indexPath)")
            return false
        }
        let id = contactList[indexPath.item].id
        let time = contactList[indexPath.item].timeStamp
        if let lastTime = idVStimeDic[id] {
            return lastTime.compare(time) == .orderedDescending
        } else {
            return false
        }
    }
}

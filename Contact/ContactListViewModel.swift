//
//  ContactListViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 14/1/22.
//

import Foundation
import ReactiveSwift

class ContactListViewModel {
    let vc: ContactListViewController
    var contactList: [FireContactItem] = [] {
        didSet {
            //inputSignal.send(value: ())
            vc.tableView.reloadData()
        }
    }
    private var shouldFetchAgain: Bool = true
    private let dataCollector = DataCollector()
    private let (outputSignal, inputSignal) = Signal<Void, Never>.pipe()
    var observeForUpdate: SignalProducer<Void, Never> { outputSignal.producer }
    
    init(vc: ContactListViewController) {
        self.vc = vc
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
                case .failure(let error):
                    print("[ContactListViewModel][fetchData] error at fetching contact data \(error)")
                }
                self.shouldFetchAgain = true
            }
        }
    }
}

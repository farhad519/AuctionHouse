//
//  CommonDataStore.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 16/3/22.
//

import Foundation

class CommonData {
    static let shared = CommonData()
    
    private let dataCollector = DataCollector()
    
    var myBidList: [FireBidItem] = []
    
    init() {
        fetchMyBidList()
    }
    
    private func fetchMyBidList() {
        dataCollector.getBidItemList().startWithResult { [weak self] result in
            switch result {
            case .success(let myBidList):
                self?.myBidList = myBidList
            case .failure(let error):
                print("[CommonData][fetchMyBidList] error at fetching bid data data \(error)")
            }
        }
    }
}

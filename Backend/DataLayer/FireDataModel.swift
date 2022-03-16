//
//  FireDataModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 19/12/21.
//

import Foundation

enum DataCollectorError: Error {
    case noSnapShot
    case noUserId
    case invalidUrl
    case failedToConvertDataToImage
    case noDataFound
    case referenceFailure
}

struct FireAuctionItem {
    var id: String
    var title: String
    var type: String
    var description: String
    var price: Double
    var negotiable: Bool
    var ownerId: String
    var videoUrlString: String
    var imagesUrlStringList: [String]
}

struct FireContactItem {
    var id: String
    var message: String
    var iconUrl: String
    var timeStamp: NSNumber
    var email: String
}

struct FireMessageItem {
    var message: String
    var timeStamp: NSNumber
}

struct FireBidItem {
    var id: String
    var timeStamp: NSNumber
}

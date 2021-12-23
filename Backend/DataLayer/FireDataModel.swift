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
}

struct FireAuctionItem {
    var title: String
    var type: String
    var description: String
    var price: Double
    var negotiable: Bool
    var ownerId: String
    var videoUrlString: String
    var imagesUrlStringList: [String]
}
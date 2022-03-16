//
//  MyKeys.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 15/12/21.
//

import Foundation

enum MyKeys: String {
    case imagesFolder = "AuctionHouse/Images"
    case videoFolder = "AuctionHouse/Videos"
    case AuctionSellItem = "AuctionSellItem"
    case recentMessages = "recent-messages"
    case userMessages = "user-messages"
    case messages = "messages"
    case recentMessagesLastRead = "recent-messages-last-read"
    case myBidList = "my-bid-list"
    enum AuctionSellItemField: String {
        case title = "title"
        case sellDescription = "sellDescription"
        case type = "type"
        case negotiable = "negotiable"
        case price = "price"
        case ownerId = "ownerId"
        case video = "video"
        case images = "images"
    }
    enum ContactItemField: String {
        case message = "message"
        case iconUrl = "iconUrl"
        case timeStamp = "timeStamp"
        case email = "email"
    }
    enum RecentMessagesLastRead: String {
        case timeStamp = "timeStamp"
        case lastRead = "lastRead"
        case contactedId = "contactedId"
    }
    enum MyBidList: String {
        case auctionId = "auctionId"
        case timeStamp = "timeStamp"
    }
}

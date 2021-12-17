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
}
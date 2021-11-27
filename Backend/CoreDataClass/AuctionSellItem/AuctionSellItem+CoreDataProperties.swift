//
//  AuctionSellItem+CoreDataProperties.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 24/11/21.
//
//

import Foundation
import CoreData

extension AuctionSellItem {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AuctionSellItem> {
        return NSFetchRequest<AuctionSellItem>(entityName: "AuctionSellItem")
    }

    @NSManaged public var image: Data?
    @NSManaged public var video: Data?
    @NSManaged public var sellDescription: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var price: Double
    @NSManaged public var negotiable: Bool
    @NSManaged public var ownerId: String?
    @NSManaged public var id: String?

}

extension AuctionSellItem : Identifiable {
}

//
//  CoreDataManager.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 2/2/22.
//

import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    func deleteAllData(entity: String) {
        let reqVar = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let delAllReqVar = NSBatchDeleteRequest(fetchRequest: reqVar)
        do { try context?.execute(delAllReqVar) }
        catch { print(error) }
    }
    
    func saveDataToStore(auctionItemDatas: [FireAuctionItem]) {
        guard let context = context else { return }
        
        deleteAllData(entity: "AuctionSellItem")
        
        auctionItemDatas.forEach {
            let auctionSellItem = AuctionSellItem(context: context)
            auctionSellItem.id = $0.id
            auctionSellItem.ownerId = $0.ownerId
            auctionSellItem.title = $0.title
            auctionSellItem.type = $0.type
            auctionSellItem.price = $0.price
            auctionSellItem.negotiable = $0.negotiable
            auctionSellItem.sellDescription = $0.description
            auctionSellItem.image = stringArrayToData(stringArray: $0.imagesUrlStringList)
            auctionSellItem.video = stringArrayToData(stringArray: [$0.videoUrlString])
        }

        do {
            try context.save()
        } catch {
            print("[CoreDataManager][saveDataToStore] could not save to store. \(error)")
        }
        
        print("[CoreDataManager][saveDataToStore] data save to core from cloud is done.")
    }
    
    func getAuctionItemDatas(myId: String, offset: Int, blockCount: Int, minV: Int, maxV: Int, searchKey: [String]) -> [FireAuctionItem] {
        guard let context = context else { return [] }
        let fetchRequest: NSFetchRequest<AuctionSellItem>
        fetchRequest = AuctionSellItem.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = blockCount
        
        let sectionSortDescriptor = NSSortDescriptor(
            key: MyKeys.AuctionSellItemField.price.rawValue,
            ascending: true
        )
        fetchRequest.sortDescriptors = [sectionSortDescriptor]

        let minPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.price) >= %@", "\(minV)"
        )

        let maxPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.price) <= %@", "\(maxV)"
        )
        
        let myAuctionListPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.ownerId) != %@", myId
        )
        
        let allLoweredCase = searchKey.map { $0.lowercased() }
        let typePredicate = NSPredicate(
            format: "\(MyKeys.AuctionSellItemField.type.rawValue) in[c] (%@)", allLoweredCase
        )
        
        if searchKey.isEmpty == false {
            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    minPredicate,
                    maxPredicate,
                    myAuctionListPredicate,
                    typePredicate
                ]
            )
        } else {
            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    minPredicate,
                    maxPredicate,
                    myAuctionListPredicate
                ]
            )
        }
        
        var auctionItems: [AuctionSellItem] = []
        do {
            try auctionItems = context.fetch(fetchRequest)
        } catch {
            print("[CoreDataManager][getAuctionItemDatas] error at fetch")
        }
        
        return auctionItems.compactMap {
            guard $0.id != nil else { return nil }
            return FireAuctionItem(
                id: $0.id ?? "",
                title: $0.title ?? "",
                type: $0.type ?? "",
                description: $0.description,
                price: $0.price,
                negotiable: $0.negotiable,
                ownerId: $0.ownerId ?? "",
                videoUrlString: dataToStringArray(data: $0.video)?.first ?? "",
                imagesUrlStringList: dataToStringArray(data: $0.image) ?? []
            )
        }
    }
    
    func getMyAuctionItemDatas(myId: String, offset: Int, blockCount: Int, minV: Int, maxV: Int, searchKey: [String]) -> [FireAuctionItem] {
        guard let context = context else { return [] }
        let fetchRequest: NSFetchRequest<AuctionSellItem>
        fetchRequest = AuctionSellItem.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = blockCount
        
        let sectionSortDescriptor = NSSortDescriptor(
            key: MyKeys.AuctionSellItemField.price.rawValue,
            ascending: true
        )
        fetchRequest.sortDescriptors = [sectionSortDescriptor]

        let minPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.price) >= %@", "\(minV)"
        )

        let maxPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.price) <= %@", "\(maxV)"
        )
        
        let myAuctionListPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.ownerId) == %@", myId
        )
        
        let allLoweredCase = searchKey.map { $0.lowercased() }
        let typePredicate = NSPredicate(
            format: "\(MyKeys.AuctionSellItemField.type.rawValue) in[c] (%@)", allLoweredCase
        )
        
        if searchKey.isEmpty == false {
            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    minPredicate,
                    maxPredicate,
                    myAuctionListPredicate,
                    typePredicate
                ]
            )
        } else {
            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    minPredicate,
                    maxPredicate,
                    myAuctionListPredicate
                ]
            )
        }
        
        var auctionItems: [AuctionSellItem] = []
        do {
            try auctionItems = context.fetch(fetchRequest)
        } catch {
            print("[CoreDataManager][getAuctionItemDatas] error at fetch")
        }
        
        return auctionItems.compactMap {
            guard $0.id != nil else { return nil }
            return FireAuctionItem(
                id: $0.id ?? "",
                title: $0.title ?? "",
                type: $0.type ?? "",
                description: $0.description,
                price: $0.price,
                negotiable: $0.negotiable,
                ownerId: $0.ownerId ?? "",
                videoUrlString: dataToStringArray(data: $0.video)?.first ?? "",
                imagesUrlStringList: dataToStringArray(data: $0.image) ?? []
            )
        }
    }
    
    func getBidAuctionItemDatas(auctionIds: [String], offset: Int, blockCount: Int, minV: Int, maxV: Int, searchKey: [String]) -> [FireAuctionItem] {
        guard let context = context else { return [] }
        let fetchRequest: NSFetchRequest<AuctionSellItem>
        fetchRequest = AuctionSellItem.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = blockCount
        
        let sectionSortDescriptor = NSSortDescriptor(
            key: MyKeys.AuctionSellItemField.price.rawValue,
            ascending: true
        )
        fetchRequest.sortDescriptors = [sectionSortDescriptor]

        let minPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.price) >= %@", "\(minV)"
        )

        let maxPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.price) <= %@", "\(maxV)"
        )
        
        let myAuctionListPredicate = NSPredicate (
            format: "\(MyKeys.AuctionSellItemField.id) in %@", auctionIds
        )
        
        let allLoweredCase = searchKey.map { $0.lowercased() }
        let typePredicate = NSPredicate(
            format: "\(MyKeys.AuctionSellItemField.type.rawValue) in[c] (%@)", allLoweredCase
        )
        
        if searchKey.isEmpty == false {
            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    minPredicate,
                    maxPredicate,
                    myAuctionListPredicate,
                    typePredicate
                ]
            )
        } else {
            fetchRequest.predicate = NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    minPredicate,
                    maxPredicate,
                    myAuctionListPredicate
                ]
            )
        }
        
        var auctionItems: [AuctionSellItem] = []
        do {
            try auctionItems = context.fetch(fetchRequest)
        } catch {
            print("[CoreDataManager][getAuctionItemDatas] error at fetch")
        }
        
        return auctionItems.compactMap {
            guard $0.id != nil else { return nil }
            return FireAuctionItem(
                id: $0.id ?? "",
                title: $0.title ?? "",
                type: $0.type ?? "",
                description: $0.description,
                price: $0.price,
                negotiable: $0.negotiable,
                ownerId: $0.ownerId ?? "",
                videoUrlString: dataToStringArray(data: $0.video)?.first ?? "",
                imagesUrlStringList: dataToStringArray(data: $0.image) ?? []
            )
        }
    }
    
    func stringArrayToData(stringArray: [String]) -> Data? {
      return try? JSONSerialization.data(withJSONObject: stringArray, options: [])
    }
    
    func dataToStringArray(data: Data?) -> [String]? {
        guard let data = data else { return nil }
      return (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String]
    }
}

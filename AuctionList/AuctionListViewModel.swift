//
//  AuctionListViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 27/11/21.
//

import CoreData
import UIKit

enum AuctionListViewType {
    case bidListView
    case createdView
    case auctionListView
}

struct AuctionListCellStruct {
    var image: UIImage
    var upperString: String
    var lowerString: String
    var sellDescription: String
    init() {
        image = UIImage()
        upperString = "0.0$"
        lowerString = "Fixed"
        sellDescription = "NA"
    }
}

class AuctionListViewModel {
    var auctionListViewType = AuctionListViewType.auctionListView
    var auctionSellItemList: [AuctionSellItem] = []
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    init(auctionListViewType: AuctionListViewType) {
        self.auctionListViewType = auctionListViewType
        loadDataFromStore()
    }
    
    func loadDataFromStore() {
        guard let context = context else { return }

        do {
            try auctionSellItemList = context.fetch(AuctionSellItem.fetchRequest())
        } catch {
            print("error at fetch")
        }
        
    }
    
    func getItem(at index: Int) -> AuctionListCellStruct {
        guard index < auctionSellItemList.count else { return AuctionListCellStruct() }
        var item = AuctionListCellStruct()
        item.upperString = "\(auctionSellItemList[index].price)$"
        item.lowerString = auctionSellItemList[index].negotiable == false ? "Fixed" : "Negotiable"
        item.sellDescription = auctionSellItemList[index].sellDescription ?? "NA"
        item.image = imagesFromCoreData(object: auctionSellItemList[index].image)?.first ?? UIImage()
        return item
    }
    
    private func imagesFromCoreData(object: Data?) -> [UIImage]? {
        guard let object = object else { return nil }
        
        var retrievedImages = [UIImage]()
        
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
            for data in dataArray {
                if let data = data as? Data, let image = UIImage(data: data) {
                    retrievedImages.append(image)
                }
            }
        }
        
        return retrievedImages
    }
}

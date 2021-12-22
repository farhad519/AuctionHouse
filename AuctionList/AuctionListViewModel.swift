//
//  AuctionListViewModel.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 27/11/21.
//

import CoreData
import UIKit

protocol AuctionListViewControllerDelegate {
    func reloadViewController()
}

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
    var auctionSellItemList: [AuctionListCellStruct] = []
    var delegate: AuctionListViewControllerDelegate?
    private let dataCollector: DataCollector
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    init(auctionListViewType: AuctionListViewType) {
        self.auctionListViewType = auctionListViewType
        self.dataCollector = DataCollector()
        setupMyAuctionListDataSource()
    }
    
    private func setupMyAuctionListDataSource() {
        dataCollector.getMySellList { [weak self] result in
            switch result {
            case .success(let auctionList):
                self?.getImageFromServer(auctionList: auctionList) { cellItemList in
                    self?.auctionSellItemList = cellItemList
                    self?.delegate?.reloadViewController()
                }
            case .failure(let error):
                print("[AuctionListViewModel][setupMyAuctionListDataSource] error at retrieving data with \(error)")
            }
        }
    }
    
    private func getImageFromServer(auctionList: [FireAuctionItem], completion: @escaping ([AuctionListCellStruct]) -> Void) {
        var cellItemList: [AuctionListCellStruct] = []
        let workGroup = DispatchGroup()
        auctionList.forEach {
            var cellItem = AuctionListCellStruct()
            cellItem.upperString = "\($0.price)$"
            cellItem.lowerString = $0.negotiable == false ? "Fixed" : "Negotiable"
            cellItem.sellDescription = $0.description
            workGroup.enter()
            dataCollector.getImage(urlString: $0.imagesUrlStringList.first ?? "") { result in
                switch result {
                case .success(let recievedImage):
                    cellItem.image = recievedImage
                    print("[AuctionListViewModel][getImageFromServer] image recieved.")
                case .failure(let error):
                    print("[AuctionListViewModel][getImageFromServer] error at retrieving image with \(error)")
                }
                cellItemList.append(cellItem)
                workGroup.leave()
            }
        }
        workGroup.notify(queue: DispatchQueue.main, execute: {
            completion(cellItemList)
        })
    }
    
    func getItem(at index: Int) -> AuctionListCellStruct {
        guard index < auctionSellItemList.count else { return AuctionListCellStruct() }
        return auctionSellItemList[index]
    }

//    func loadDataFromStore() {
//        guard let context = context else { return }
//
//        do {
//            try auctionSellItemList = context.fetch(AuctionSellItem.fetchRequest())
//        } catch {
//            print("error at fetch")
//        }
//    }
//
//    private func imagesFromCoreData(object: Data?) -> [UIImage]? {
//        guard let object = object else { return nil }
//
//        var retrievedImages = [UIImage]()
//
//        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: object) {
//            for data in dataArray {
//                if let data = data as? Data, let image = UIImage(data: data) {
//                    retrievedImages.append(image)
//                }
//            }
//        }
//
//        return retrievedImages
//    }
}

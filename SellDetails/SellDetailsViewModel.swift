//
//  SellDetailsViewModel.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 5/11/21.
//

import UIKit
import CoreData

enum SellDetailsEditedEnum {
    case title
    case type
    case price
    case negotiable
    case description
}

struct SellDetailsEditedValue {
    var title: String
    var type: String
    var price: String
    var negotiable: String
    var description: String
}

final class SellDetailsViewModel {
    let descriptionTextViewPlaceHolder = TextViewPlaceHolder("Write description here .....")
    var editedValue: SellDetailsEditedValue
    var imageList: [UIImage] = []
    var videoList: [URL] = []
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    init() {
        editedValue = SellDetailsEditedValue(
            title: "",
            type: "",
            price: "",
            negotiable: "",
            description: ""
        )
    }
    
    func isEmpty(string: String) -> Bool {
        for ch in string {
            if ch != "\n" && ch != " " {
                return false
            }
            return true
        }
        return true
    }
    
    func getEditedText(for editedEnum: SellDetailsEditedEnum) -> String {
        switch editedEnum {
        case .title:
            return isEmpty(string: editedValue.title) ? "" : editedValue.title
        case .type:
            return isEmpty(string: editedValue.type) ? "" : editedValue.type
        case .price:
            return isEmpty(string: editedValue.price) ? "" : editedValue.price
        case .negotiable:
            return isEmpty(string: editedValue.negotiable) ? "" : editedValue.negotiable
        case .description:
            return isEmpty(string: editedValue.description) ? "" : editedValue.description
        }
    }
    
    func saveDataToStore(completion: () -> Void) {
        guard let context = context else { return }
        let auctionSellItem = AuctionSellItem(context: context)
        auctionSellItem.title = editedValue.title
        auctionSellItem.type = editedValue.type
        auctionSellItem.price = Double(editedValue.price) ?? 0.0
        auctionSellItem.negotiable = (editedValue.negotiable.lowercased() == "yes") ? true : false
        auctionSellItem.sellDescription = editedValue.description
        auctionSellItem.image = coreDataObjectFromImages()
        auctionSellItem.video = coreDataObjectFromVideo()
        do {
            try context.save()
            completion()
        } catch {
            print("could not save to store. \(error)")
            completion()
        }
    }
    
    private func coreDataObjectFromVideo() -> Data? {
        guard let url = videoList.first else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("error caught \(error)")
            return nil
        }
    }
    
    private func coreDataObjectFromImages() -> Data? {
        let dataArray = NSMutableArray()
        
        for image in imageList {
            if let data = image.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }

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

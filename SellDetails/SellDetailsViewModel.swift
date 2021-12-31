//
//  SellDetailsViewModel.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 5/11/21.
//

import UIKit
import CoreData
import Firebase
import FirebaseStorage

enum SellDetailsViewType {
    case forCreate
    case forModify
    case forBid
}

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

struct ImageUrlCouple {
    var image: UIImage
    var urlString: String
    var isFromCloud: Bool
}

final class SellDetailsViewModel {
    let descriptionTextViewPlaceHolder = TextViewPlaceHolder("Write description here .....")
    var editedValue: SellDetailsEditedValue
    var imageList: [UIImage] {
        imageUrlList.compactMap {
            guard let data = try? Data(contentsOf: $0) else { return nil }
            return UIImage(data: data)
        }
    }
    var imageUrlList: [URL] = []
    var videoList: [URL] = []
    
    private var context: NSManagedObjectContext? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    }
    
    var viewType: SellDetailsViewType
    var fireAuctionItem: FireAuctionItem?
    
    init(viewType: SellDetailsViewType) {
        editedValue = SellDetailsEditedValue(
            title: "",
            type: "",
            price: "",
            negotiable: "",
            description: ""
        )
        self.viewType = viewType
    }
    
    init(viewType: SellDetailsViewType, fireAuctionItem: FireAuctionItem) {
        self.fireAuctionItem = fireAuctionItem
        editedValue = SellDetailsEditedValue(
            title: fireAuctionItem.title,
            type: fireAuctionItem.type,
            price: String(fireAuctionItem.price),
            negotiable: fireAuctionItem.negotiable ? "yes" : "no",
            description: fireAuctionItem.description
        )
        self.viewType = viewType
    }
    
    func isAnyFieldEmpty() -> String? {
        if imageUrlList.isEmpty {
            return "Need at least one image of the product."
        }
        if editedValue.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need description about the product."
        }
        if editedValue.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need title about the product."
        }
        if editedValue.type.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need type about the product."
        }
        if editedValue.price.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Need price for the product."
        }
        return nil
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
    
//    func saveDataToStore(completion: () -> Void) {
//        guard let context = context else { return }
//        let auctionSellItem = AuctionSellItem(context: context)
//        auctionSellItem.title = editedValue.title
//        auctionSellItem.type = editedValue.type
//        auctionSellItem.price = Double(editedValue.price) ?? 0.0
//        auctionSellItem.negotiable = (editedValue.negotiable.lowercased() == "yes") ? true : false
//        auctionSellItem.sellDescription = editedValue.description
//        auctionSellItem.image = coreDataObjectFromImages()
//        auctionSellItem.video = coreDataObjectFromVideo()
//        do {
//            try context.save()
//            completion()
//        } catch {
//            print("could not save to store. \(error)")
//            completion()
//        }
//        saveDataToFireStore()
//    }
    
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
    
    func saveDataToFireStore(completion: @escaping () -> Void) {
        let workGroup = DispatchGroup()
        var videoUrlString: String = ""
        var imageUrlStringList: [String] = []
        
        workGroup.enter()
        getSavedUrlForVideo { url in
            videoUrlString = url?.absoluteString ?? ""
            workGroup.leave()
        }
        
        workGroup.enter()
        getSavedUrlForImages { imagesUrlList in
            imageUrlStringList = imagesUrlList.compactMap { $0.absoluteString }
            workGroup.leave()
        }
        
        let negotiableValue = (editedValue.negotiable.lowercased() == "yes") ? true : false
        let priceValue = Double(editedValue.price) ?? 0.0
        guard let ownerId = Auth.auth().currentUser?.uid else { return }
        
        workGroup.notify(queue: DispatchQueue.main, execute: { [weak self] in
            guard let editedValue = self?.editedValue else {
                completion()
                return
            }
            let db = Firestore.firestore()
            db
                .collection(MyKeys.AuctionSellItem.rawValue)
                .addDocument(
                    data: [
                        MyKeys.AuctionSellItemField.title.rawValue: editedValue.title,
                        MyKeys.AuctionSellItemField.sellDescription.rawValue: editedValue.description,
                        MyKeys.AuctionSellItemField.type.rawValue: editedValue.type,
                        MyKeys.AuctionSellItemField.negotiable.rawValue: negotiableValue,
                        MyKeys.AuctionSellItemField.price.rawValue: priceValue,
                        MyKeys.AuctionSellItemField.ownerId.rawValue: ownerId,
                        MyKeys.AuctionSellItemField.video.rawValue: videoUrlString,
                        MyKeys.AuctionSellItemField.images.rawValue: imageUrlStringList,
                    ]
                ) { error in
                    completion()
                    guard error == nil else { return }
                }
        })
        
    }
    
    func getSavedUrlForImages(completion: @escaping ([URL]) -> Void) {
        let workGroup = DispatchGroup()
        var urlList: [URL] = []
        let storage = Storage.storage()
        imageUrlList.forEach {
            let imageUID = UUID().uuidString
            let storageRef = storage.reference()
                .child(MyKeys.imagesFolder.rawValue)
                .child(imageUID)
            workGroup.enter()
            storageRef.putFile(from: $0, metadata: nil) { (metadata, error) in
                guard error == nil else {
                    workGroup.leave()
                    return
                }
                storageRef.downloadURL { (url, error) in
                    guard let url = url else {
                        workGroup.leave()
                        return
                    }
                    urlList.append(url)
                    workGroup.leave()
                }
            }
        }
        
        workGroup.notify(queue: DispatchQueue.main, execute: {
            completion(urlList)
        })
    }
    
    func getSavedUrlForVideo(completion: @escaping (URL?) -> Void) {
        guard let url = videoList.first else {
            completion(nil)
            return
        }
        let storage = Storage.storage()
        let videoUID = UUID().uuidString
        let storageRef = storage.reference()
            .child(MyKeys.videoFolder.rawValue)
            .child(videoUID)
        storageRef.putFile(from: url, metadata: nil) { (metadata, error) in
            guard error == nil else { return }
            storageRef.downloadURL { (url, error) in
                guard let url = url else { return }
                completion(url)
            }
        }
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

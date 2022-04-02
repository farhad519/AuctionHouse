//
//  DataCollector.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 19/12/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import ReactiveSwift

class DataCollector {
    static var imageCache = NSCache<NSString, UIImage>()
    func getMySellList(completion: @escaping (Result<[FireAuctionItem], Error>) -> Void) {
        guard let idValue = Auth.auth().currentUser?.uid else {
            print("[DataCollector][getMySellList] can not find uid")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        let query = Firestore.firestore().collection(MyKeys.AuctionSellItem.rawValue)
            .whereField(MyKeys.AuctionSellItemField.ownerId.rawValue, isEqualTo: idValue)
        query.getDocuments { (snapShot, error) in
            print("[DataCollector][getMySellList] auction item recieved \(String(describing: error)).")
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            let auctionItemDatas = snapShot.documents.compactMap { document in
                FireAuctionItem(
                    id: document.documentID,
                    title: document[MyKeys.AuctionSellItemField.title.rawValue] as? String ?? "",
                    type: document[MyKeys.AuctionSellItemField.type.rawValue] as? String ?? "",
                    description: document[MyKeys.AuctionSellItemField.sellDescription.rawValue] as? String ?? "",
                    price: document[MyKeys.AuctionSellItemField.price.rawValue] as? Double ?? 0.0,
                    negotiable: document[MyKeys.AuctionSellItemField.negotiable.rawValue] as? Bool ?? false,
                    ownerId: document[MyKeys.AuctionSellItemField.ownerId.rawValue] as? String ?? "",
                    videoUrlString: document[MyKeys.AuctionSellItemField.video.rawValue] as? String ?? "",
                    imagesUrlStringList: document[MyKeys.AuctionSellItemField.images.rawValue] as? [String] ?? []
                )
            }
            completion(.success(auctionItemDatas))
        }
    }
    
    func getAllSellList() {
        let query = Firestore.firestore().collection(MyKeys.AuctionSellItem.rawValue)

        query.getDocuments { (snapShot, error) in
            print("[DataCollector][getAllSellList] auction item recieved \(String(describing: error)).")
            if let _ = error {
                return
            }
            guard let snapShot = snapShot else {
                print("[DataCollector][getAllSellList] snapshot found nil.")
                return
            }
            let auctionItemDatas = snapShot.documents.compactMap { document in
                FireAuctionItem(
                    id: document.documentID,
                    title: document[MyKeys.AuctionSellItemField.title.rawValue] as? String ?? "",
                    type: document[MyKeys.AuctionSellItemField.type.rawValue] as? String ?? "",
                    description: document[MyKeys.AuctionSellItemField.sellDescription.rawValue] as? String ?? "",
                    price: document[MyKeys.AuctionSellItemField.price.rawValue] as? Double ?? 0.0,
                    negotiable: document[MyKeys.AuctionSellItemField.negotiable.rawValue] as? Bool ?? false,
                    ownerId: document[MyKeys.AuctionSellItemField.ownerId.rawValue] as? String ?? "",
                    videoUrlString: document[MyKeys.AuctionSellItemField.video.rawValue] as? String ?? "",
                    imagesUrlStringList: document[MyKeys.AuctionSellItemField.images.rawValue] as? [String] ?? []
                )
            }
            print("[DataCollector][getAllSellList] retrieved from cloud all sell item = \(auctionItemDatas.count)")
            CoreDataManager.shared.saveDataToStore(auctionItemDatas: auctionItemDatas)
        }
    }
    
    func getAuctionSellItem(by auctionItemid: String, completion: @escaping (Result<FireAuctionItem, Error>) -> Void) {
        let query = Firestore.firestore().collection(MyKeys.AuctionSellItem.rawValue)
            .whereField("id", isEqualTo: auctionItemid)
        query.getDocuments { (snapShot, error) in
            print("[DataCollector][getAuctionSellItem] auction item recieved \(String(describing: error)).")
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            let auctionItemDatas = snapShot.documents.compactMap { document in
                FireAuctionItem(
                    id: document.documentID,
                    title: document[MyKeys.AuctionSellItemField.title.rawValue] as? String ?? "",
                    type: document[MyKeys.AuctionSellItemField.type.rawValue] as? String ?? "",
                    description: document[MyKeys.AuctionSellItemField.sellDescription.rawValue] as? String ?? "",
                    price: document[MyKeys.AuctionSellItemField.price.rawValue] as? Double ?? 0.0,
                    negotiable: document[MyKeys.AuctionSellItemField.negotiable.rawValue] as? Bool ?? false,
                    ownerId: document[MyKeys.AuctionSellItemField.ownerId.rawValue] as? String ?? "",
                    videoUrlString: document[MyKeys.AuctionSellItemField.video.rawValue] as? String ?? "",
                    imagesUrlStringList: document[MyKeys.AuctionSellItemField.images.rawValue] as? [String] ?? []
                )
            }
            if let firstItem = auctionItemDatas.first {
                completion(.success(firstItem))
            } else {
                completion(.failure(DataCollectorError.noDataFound))
            }
        }
    }
    
    func getImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(DataCollectorError.invalidUrl))
            return
        }
        if let cachedImage = DataCollector.imageCache.object(forKey: urlString as NSString) {
            completion(.success(cachedImage))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            //print("[DataCollector][getImage] response \(String(describing: response))")
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(DataCollectorError.failedToConvertDataToImage))
                return
            }
            DataCollector.imageCache.setObject(image, forKey: urlString as NSString)
            completion(.success(image))
        }.resume()
    }
    
//    func observeMessages() {
//        let userMessagesObserver = Firestore.firestore()
//            .collection("user-messages")
//            .document("fromId")
//        userMessagesObserver.addSnapshotListener { (documentSnapshot, error) in
//            
//            print("listener found ...... \(error)")
//        }
//
//        let userMessagesRef = Firestore.firestore()
//            .collection("user-messages")
//            .document("fromId")
//            .collection("toId2")
//        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
//        let values: [String : Any] = [
//            "id2": "id1234",
//            "timestamp": timestamp
//        ]
//        userMessagesRef.addDocument(data: values)
//        userMessagesRef.addDocument(data: values)
//    }
    
    func postRecentMessagesLastReadTime(toId: String) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][postRecentMessagesLastReadTime] can not find self uid")
            return
        }

        guard toId.isEmpty == false else {
            print("[DataCollector][postRecentMessagesLastReadTime] toId is empty")
            return
        }
        
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let data: [String: Any] = [
            MyKeys.RecentMessagesLastRead.timeStamp.rawValue: timestamp,
            MyKeys.RecentMessagesLastRead.contactedId.rawValue: toId
        ]
        let recentMessagesRef = Firestore.firestore()
            .collection(MyKeys.recentMessagesLastRead.rawValue)
            .document(fromId)
            .collection(MyKeys.RecentMessagesLastRead.lastRead.rawValue)
            .document(toId)
        recentMessagesRef.setData(data)
    }
    
    func getRecentMessagesLastReadTime() -> SignalProducer<[String: NSNumber], Error> {
        SignalProducer { [weak self] (observer, disposable) in
            guard let self = self else {
                observer.send(error: DataCollectorError.referenceFailure)
                return
            }
            self.getRecentMessagesLastReadTime() { result in
                switch result {
                case .success(let idVStimeDic):
                    observer.send(value: idVStimeDic)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
    
    private func getRecentMessagesLastReadTime(completion: @escaping (Result<[String: NSNumber], Error>) -> Void) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][getRecentMessagesLastReadTime] can not find self uid")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        let recentMessagesRef = Firestore.firestore()
            .collection(MyKeys.recentMessagesLastRead.rawValue)
            .document(fromId)
            .collection(MyKeys.RecentMessagesLastRead.lastRead.rawValue)
        recentMessagesRef.getDocuments { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            var idVStimeDic: [String: NSNumber] = [:]
            snapShot.documents.forEach {
                idVStimeDic[$0.documentID] = $0[MyKeys.RecentMessagesLastRead.timeStamp.rawValue] as? NSNumber ?? NSNumber(value: 0)
            }
            print("[DataCollector][getRecentMessagesLastReadTime] received contact data \(idVStimeDic.count)")
            completion(.success(idVStimeDic))
        }
    }
    
    func postRecentMessages(message: String, iconUrl: String, toId: String) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][postRecentMessages] can not find self uid")
            return
        }
        guard let email = Auth.auth().currentUser?.email else {
            print("[DataCollector][postRecentMessages] can not find email")
            return
        }
        guard toId.isEmpty == false else {
            print("[DataCollector][postRecentMessages] toId is empty")
            return
        }
        
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let data: [String: Any] = [
            MyKeys.ContactItemField.message.rawValue: message,
            MyKeys.ContactItemField.iconUrl.rawValue: iconUrl,
            MyKeys.ContactItemField.timeStamp.rawValue: timestamp,
            MyKeys.ContactItemField.email.rawValue: email
        ]
        let recentMessagesRef = Firestore.firestore()
            .collection(MyKeys.recentMessages.rawValue)
            .document(toId)
            .collection(MyKeys.messages.rawValue)
            .document(fromId)
        recentMessagesRef.setData(data)
    }
    
    func getRecentMessages() -> SignalProducer<[FireContactItem], Error> {
        SignalProducer { [weak self] (observer, disposable) in
            guard let self = self else {
                observer.sendCompleted()
                return
            }
            self.getRecentMessages() { result in
                switch result {
                case .success(let fireContactItemList):
                    observer.send(value: fireContactItemList)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
    
    private func getRecentMessages(completion: @escaping (Result<[FireContactItem], Error>) -> Void) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][postRecentMessages] can not find self uid")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        let recentMessagesRef = Firestore.firestore()
            .collection(MyKeys.recentMessages.rawValue)
            .document(fromId)
            .collection(MyKeys.messages.rawValue)
            .order(by: MyKeys.ContactItemField.timeStamp.rawValue)
            .limit(to: 10)
        recentMessagesRef.getDocuments { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            let contactItemDatas = snapShot.documents.compactMap { document in
                FireContactItem(
                    id: document.documentID,
                    message: document[MyKeys.ContactItemField.message.rawValue] as? String ?? "",
                    iconUrl: document[MyKeys.ContactItemField.iconUrl.rawValue] as? String ?? "",
                    timeStamp: document[MyKeys.ContactItemField.timeStamp.rawValue] as? NSNumber ?? NSNumber(value: 0),
                    email: document[MyKeys.ContactItemField.email.rawValue] as? String ?? ""
                )
            }
            print("[DataCollector][postRecentMessages] received contact data \(contactItemDatas.count)")
            completion(.success(contactItemDatas))
        }
    }
    
    func postDirectMessages(message: String, timeStamp: NSNumber, toId: String) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][postDirectMessages] can not find self uid")
            return
        }
        guard toId.isEmpty == false else {
            print("[DataCollector][postDirectMessages] toId is empty")
            return
        }
        
        let data: [String: Any] = [
            MyKeys.ContactItemField.message.rawValue: message,
            MyKeys.ContactItemField.timeStamp.rawValue: timeStamp
        ]
        let directMessagesRef = Firestore.firestore()
            .collection(MyKeys.userMessages.rawValue)
            .document(toId)
            .collection(fromId)
        directMessagesRef.addDocument(data: data)
    }
    
    func getDirectMessages(toId: String) -> SignalProducer<[FireMessageItem], Error> {
        SignalProducer { [weak self] (observer, disposable) in
            guard let self = self else {
                observer.sendCompleted()
                return
            }
            self.getDirectMessages(toId: toId) { result in
                switch result {
                case .success(let fireMessageItemList):
                    observer.send(value: fireMessageItemList)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
    
    private func getDirectMessages(toId: String, completion: @escaping (Result<[FireMessageItem], Error>) -> Void) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][getDirectMessages] can not find self uid")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        guard toId.isEmpty == false else {
            print("[DataCollector][getDirectMessages] toId is empty.")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        let directMessagesRef = Firestore.firestore()
            .collection(MyKeys.userMessages.rawValue)
            .document(fromId)
            .collection(toId)
            .order(by: MyKeys.ContactItemField.timeStamp.rawValue)
            .limit(to: 30)
        directMessagesRef.getDocuments { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            let messageItemDatas = snapShot.documents.compactMap { document in
                FireMessageItem(
                    message: document[MyKeys.ContactItemField.message.rawValue] as? String ?? "",
                    timeStamp: document[MyKeys.ContactItemField.timeStamp.rawValue] as? NSNumber ?? NSNumber(value: 0)
                )
            }
            print("[DataCollector][getDirectMessages] received message data \(messageItemDatas.count)")
            completion(.success(messageItemDatas))
        }
    }
    
    func getMyDirectMessages(toId: String, completion: @escaping (Result<[FireMessageItem], Error>) -> Void) {
        guard let fromId = Auth.auth().currentUser?.uid else {
            print("[DataCollector][getMyDirectMessages] can not find self uid")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        guard toId.isEmpty == false else {
            print("[DataCollector][getMyDirectMessages] toId is empty.")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        let directMessagesRef = Firestore.firestore()
            .collection(MyKeys.userMessages.rawValue)
            .document(toId)
            .collection(fromId)
            .order(by: MyKeys.ContactItemField.timeStamp.rawValue)
            .limit(to: 100)
        directMessagesRef.getDocuments { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            let messageItemDatas = snapShot.documents.compactMap { document in
                FireMessageItem(
                    message: document[MyKeys.ContactItemField.message.rawValue] as? String ?? "",
                    timeStamp: document[MyKeys.ContactItemField.timeStamp.rawValue] as? NSNumber ?? NSNumber(value: 0)
                )
            }
            print("[DataCollector][getMyDirectMessages] received message data \(messageItemDatas.count)")
            completion(.success(messageItemDatas))
        }
    }
    
    func postBidItem(auctionId: String) {
        guard let id = Auth.auth().currentUser?.uid else {
            print("[DataCollector][postBidItem] can not find self uid")
            return
        }
        
        let timestamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let data: [String: Any] = [
            MyKeys.MyBidList.auctionId.rawValue: auctionId,
            MyKeys.MyBidList.timeStamp.rawValue: timestamp
        ]
        let ref = Firestore.firestore()
            .collection(MyKeys.myBidList.rawValue)
            .document(id)
            .collection(MyKeys.myBidList.rawValue)
        ref.addDocument(data: data)
    }
    
    func getBidItemList() -> SignalProducer<[FireBidItem], Error> {
        SignalProducer { [weak self] (observer, disposable) in
            guard let self = self else {
                observer.send(error: DataCollectorError.referenceFailure)
                return
            }
            self.getBidItemList() { result in
                switch result {
                case .success(let bidItemList):
                    observer.send(value: bidItemList)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
    
    private func getBidItemList(completion: @escaping (Result<[FireBidItem], Error>) -> Void) {
        guard let id = Auth.auth().currentUser?.uid else {
            print("[DataCollector][getBidItemList] can not find self uid")
            completion(.failure(DataCollectorError.noUserId))
            return
        }
        let ref = Firestore.firestore()
            .collection(MyKeys.myBidList.rawValue)
            .document(id)
            .collection(MyKeys.myBidList.rawValue)
            .limit(to: 100)
        ref.getDocuments { (snapShot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            
            let bidList = snapShot.documents.map { document in
                FireBidItem(
                    id: document[MyKeys.MyBidList.auctionId.rawValue] as? String ?? "",
                    timeStamp: document[MyKeys.MyBidList.timeStamp.rawValue] as? NSNumber ?? NSNumber(value: 0)
                )
            }
            print("[DataCollector][getBidItemList] received bid data \(bidList.count)")
            completion(.success(bidList))
        }
    }
    
    func getEmail(with id: String) -> SignalProducer<String, Error> {
        SignalProducer { [weak self] (observer, disposable) in
            guard let self = self else {
                observer.send(error: DataCollectorError.referenceFailure)
                return
            }
            self.getEmail(with: id) { result in
                switch result {
                case .success(let email):
                    observer.send(value: email)
                    observer.sendCompleted()
                case .failure(let error):
                    observer.send(error: error)
                }
            }
        }
    }
    
    private func getEmail(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        let query = Firestore.firestore().collection(MyKeys.users.rawValue)
            .whereField(MyKeys.Users.uid.rawValue, isEqualTo: id)
        query.getDocuments { (snapShot, error) in
            print("[DataCollector][getEmail] email recieved \(String(describing: error)).")
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapShot = snapShot else {
                completion(.failure(DataCollectorError.noSnapShot))
                return
            }
            let emails = snapShot.documents.compactMap { document in
                document[MyKeys.Users.email.rawValue] as? String ?? ""
            }
            completion(.success(emails.first ?? ""))
        }
    }
}

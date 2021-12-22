//
//  DataCollector.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 19/12/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class DataCollector {
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
            let auctionItemDatas = snapShot.documents.compactMap { doucment in
                FireAuctionItem(
                    title: doucment[MyKeys.AuctionSellItemField.title.rawValue] as? String ?? "",
                    type: doucment[MyKeys.AuctionSellItemField.type.rawValue] as? String ?? "",
                    description: doucment[MyKeys.AuctionSellItemField.sellDescription.rawValue] as? String ?? "",
                    price: doucment[MyKeys.AuctionSellItemField.price.rawValue] as? Double ?? 0.0,
                    negotiable: doucment[MyKeys.AuctionSellItemField.negotiable.rawValue] as? Bool ?? false,
                    ownerId: doucment[MyKeys.AuctionSellItemField.ownerId.rawValue] as? String ?? "",
                    videoUrlString: doucment[MyKeys.AuctionSellItemField.video.rawValue] as? String ?? "",
                    imagesUrlStringList: doucment[MyKeys.AuctionSellItemField.images.rawValue] as? [String] ?? []
                )
            }
            completion(.success(auctionItemDatas))
        }
    }
    
    func getImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(DataCollectorError.invalidUrl))
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
            completion(.success(image))
        }.resume()
    }
}

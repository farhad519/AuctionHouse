//
//  SellDetailsViewModel.swift
//  Buy And Sell App
//
//  Created by Farhad Chowdhury on 5/11/21.
//

import UIKit

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
}

//
//  CommonCode.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 19/12/21.
//

import UIKit

protocol PropertyLoopable {
    func allProperties() throws -> [String: Any]
}
extension PropertyLoopable {
    func allProperties() throws -> [String: Any] {

        var result: [String: Any] = [:]

        let mirror = Mirror(reflecting: self)

        // Optional check to make sure we're iterating over a struct or class
        guard let style = mirror.displayStyle, style == .struct || style == .class else {
            throw NSError()
        }

        for (property, value) in mirror.children {
            guard let property = property else {
                continue
            }

            result[property] = value
        }

        return result
    }
}

protocol PropertySubscriptable { }
extension PropertySubscriptable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        for child in m.children {
            if child.label == key { return child.value }
        }
        return nil
    }
}

struct CustomColor {
    struct Color {
        let groundLevelColor: UIColor
        let firstLevelColor: UIColor
        let secondLevelColor: UIColor
    }
    
    static let colorRange = (1...9)
    var value: Color {
        switch colorSpectrumValue {
        case 1:
            return Color(
                groundLevelColor: UIColor(hex: "03396c"),
                firstLevelColor: UIColor(hex: "005b96"),
                secondLevelColor: UIColor(hex: "6497b1")
            )
        case 2:
//            return Color(
//                groundLevelColor: UIColor(hex: "009688"),
//                firstLevelColor: UIColor(hex: "35a79c"),
//                secondLevelColor: UIColor(hex: "65c3ba")
//            )
            return Color(
                groundLevelColor: UIColor(hex: "011f4b"),
                firstLevelColor: UIColor(hex: "03396c"),
                secondLevelColor: UIColor(hex: "005b96")
            )
        case 3:
//            return Color(
//                groundLevelColor: UIColor(hex: "c99789"),
//                firstLevelColor: UIColor(hex: "dfa290"),
//                secondLevelColor: UIColor(hex: "e0a899")
//            )
            return Color(
                groundLevelColor: UIColor(hex: "011f4b"),
                firstLevelColor: UIColor(hex: "03396c"),
                secondLevelColor: UIColor(hex: "005b96")
            )
        case 4:
            return Color(
                groundLevelColor: UIColor(hex: "8d5524"),
                firstLevelColor: UIColor(hex: "c68642"),
                secondLevelColor: UIColor(hex: "e0ac69")
            )
        case 5:
            return Color(
                groundLevelColor: UIColor(hex: "343d46"),
                firstLevelColor: UIColor(hex: "4f5b66"),
                secondLevelColor: UIColor(hex: "65737e")
            )
        case 6:
//            return Color(
//                groundLevelColor: UIColor(hex: "3b7dd8"),
//                firstLevelColor: UIColor(hex: "4a91f2"),
//                secondLevelColor: UIColor(hex: "64a1f4")
//            )
            return Color(
                groundLevelColor: UIColor(hex: "011f4b"),
                firstLevelColor: UIColor(hex: "03396c"),
                secondLevelColor: UIColor(hex: "005b96")
            )
        case 7:
//            return Color(
//                groundLevelColor: UIColor(hex: "3b5998"),
//                firstLevelColor: UIColor(hex: "8b9dc3"),
//                secondLevelColor: UIColor(hex: "dfe3ee")
//            )
            return Color(
                groundLevelColor: UIColor(hex: "011f4b"),
                firstLevelColor: UIColor(hex: "03396c"),
                secondLevelColor: UIColor(hex: "005b96")
            )
        case 8:
            return Color(
                groundLevelColor: UIColor(hex: "011f4b"),
                firstLevelColor: UIColor(hex: "03396c"),
                secondLevelColor: UIColor(hex: "005b96")
            )
        case 9:
            return Color(
                groundLevelColor: UIColor(hex: "1A4314"),
                firstLevelColor: UIColor(hex: "2C5E1A"),
                secondLevelColor: UIColor(hex: "59981A")
            )
        default:
            return Color(
                groundLevelColor: .white,
                firstLevelColor: .white,
                secondLevelColor: .white
            )
        }
    }
    
    let colorSpectrumValue: Int
    init(colorSpectrumValue: Int = 0) {
        self.colorSpectrumValue = colorSpectrumValue
    }
}

class CommonCalculation {
    static let shared = CommonCalculation()
    func getColorFor(str: String) -> UIColor? {
        guard str.count != 0 else { return nil }
        var str = str
        if str.count % 3 == 1 {
            str += "aa"
        } else if str.count % 3 == 2 {
            str += "a"
        }
        let maxLength = (str.count + 0) / 3
        let subStrArr = splitString(with: str, withMaxLength: maxLength)
        guard subStrArr.count >= 3 else { return nil }
        let rC = getColorValueFromString(str: subStrArr[0])
        let gC = getColorValueFromString(str: subStrArr[1])
        let bC = getColorValueFromString(str: subStrArr[2])
        return UIColor(
            red: rC,
            green: gC,
            blue: bC,
            alpha: 1
        )
    }
    
    private func splitString(with str: String, withMaxLength length: Int) -> [String] {
        return stride(from: 0, to: str.count, by: length).map {
            let start = str.index(str.startIndex, offsetBy: $0)
            let end = str.index(start, offsetBy: length, limitedBy: str.endIndex) ?? str.endIndex
            return String(str[start..<end])
        }
    }
    
    private func getColorValueFromString(str: String) -> CGFloat {
        var sum = 0
        var idx = 1
        for c in str {
            let asciiValue = Int(c.asciiValue ?? 0)
            let mulvalue = (asciiValue * idx) % 256
            sum = (sum + mulvalue) % 256
            idx += 1
        }
        return CGFloat(CGFloat(sum) / 255.0)
    }
}

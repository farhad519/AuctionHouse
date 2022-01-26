//
//  MyMessageCollectionViewCell.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 23/1/22.
//

import UIKit

class MyMessageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var myMessageTextView: UITextView!
    @IBOutlet weak var leftExtraSpace: NSLayoutConstraint!
    @IBOutlet weak var myMessageCellRightInset: NSLayoutConstraint!
    
    func setupCell(
        message: String,
        font: UIFont,
        insetSize: CGFloat,
        leftSpace: CGFloat,
        oneLineSize: CGFloat,
        trailingInset: CGFloat
    ) {
        myMessageTextView.text = message
        
        leftExtraSpace.constant = leftSpace
        myMessageCellRightInset.constant = trailingInset
        
        myMessageTextView.font = font
        myMessageTextView.backgroundColor = UIColor(hex: "C4C4C4")
        myMessageTextView.textAlignment = .right
        myMessageTextView.layer.cornerRadius = oneLineSize / 2
        myMessageTextView.layer.masksToBounds = true
        myMessageTextView.isScrollEnabled = false
        myMessageTextView.isEditable = false
        myMessageTextView.textContainerInset = UIEdgeInsets(
            top: insetSize,
            left: insetSize,
            bottom: insetSize,
            right: insetSize
        )
        myMessageTextView.textContainer.lineFragmentPadding = 0
    }
}

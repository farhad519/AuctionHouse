//
//  OtherMessageCollectionViewCell.swift
//  AuctionHouse
//
//  Created by Farhad Chowdhury on 23/1/22.
//

import UIKit

class OtherMessageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var otherMessageTextView: UITextView!
    @IBOutlet weak var otherImageView: UIImageView!
    @IBOutlet weak var otherImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var otherImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var rightExtraSpace: NSLayoutConstraint!
    @IBOutlet weak var otherMessageCellLeftInset: NSLayoutConstraint!
    @IBOutlet weak var otherLabelView: UILabel!
    
    func setupCell(
        email: String,
        message: String,
        image: UIImage,
        font: UIFont,
        color: UIColor,
        imageSize: CGFloat,
        insetSize: CGFloat,
        rightSpace: CGFloat,
        leadingInset: CGFloat
    ) {
        otherMessageTextView.text = message
        otherImageView.image = image
        
        rightExtraSpace.constant = rightSpace
        otherMessageCellLeftInset.constant = leadingInset
        
        otherMessageTextView.font = font
        otherMessageTextView.backgroundColor = color
        otherMessageTextView.textColor = .white
        otherMessageTextView.textAlignment = .left
        otherMessageTextView.layer.cornerRadius = imageSize / 2
        otherMessageTextView.layer.masksToBounds = true
        otherMessageTextView.isScrollEnabled = false
        otherMessageTextView.isEditable = false
        otherMessageTextView.textContainerInset = UIEdgeInsets(
            top: insetSize,
            left: insetSize,
            bottom: insetSize,
            right: insetSize
        )
        otherMessageTextView.textContainer.lineFragmentPadding = 0
        
        otherImageView.contentMode = .scaleAspectFill
        otherImageViewWidth.constant = imageSize
        otherImageViewHeight.constant = imageSize
        otherImageView.layer.cornerRadius = imageSize / 2
        
        otherImageView.isHidden = true
        otherLabelView.textColor = .white
        otherLabelView.text = String(email.prefix(1))
        otherLabelView.backgroundColor = CommonCalculation.shared.getColorFor(str: email)
        otherLabelView.font = .systemFont(ofSize: 10)
        otherLabelView.textAlignment = .center
        otherLabelView.clipsToBounds = true
        otherLabelView.layer.cornerRadius = imageSize / 2
    }
}

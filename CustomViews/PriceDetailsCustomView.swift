import UIKit

class PriceDetailsCustomView: UIView {
    private var parentViewController: UIViewController?
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private let textFieldInset: CGFloat = 10
    
    //private var enablingList: [(Bool) -> Void] = []
    private var textFieldList: [UITextField] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, viewController: UIViewController) {
        self.init(frame: frame)
        self.parentViewController = viewController
    }

    convenience init(viewController: UIViewController) {
        self.init(frame: .zero)
        self.parentViewController = viewController
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func draw(_ rect: CGRect) {
        selfWidth = rect.width
        selfHeight = rect.height

        //self.backgroundColor = .blue
        //configurePriceDetailsView()
    }
    
    func editTouchEnability(with value: Bool) {
        textFieldList.forEach {
            $0.isEnabled = value
        }
    }
    
    func configurePriceDetailsView() {
        let titleText: [String] = [
            "title",
            "type",
            "price",
            "negotiable"
        ]
        let placeHolderText: [String] = [
            "title",
            "type eg: book, phone etc",
            "price in dollar",
            "negotiable or fixed"
        ]
        let containerView = UIView()
        //containerView.backgroundColor = .blue
        containerView.frame = CGRect(
            x: textFieldInset,
            y: textFieldInset,
            width: selfWidth - (2 * textFieldInset),
            height: selfHeight - (2 * textFieldInset)
        )
        containerView.layer.cornerRadius = selfHeight / 10
        containerView.layer.borderWidth = 0.2
        self.addSubview(containerView)
        
        let interRowSpace: CGFloat = 10
        let interColSpace: CGFloat = 10
        let rowWidthForLabel: CGFloat = 100
        let rowWidthForTextView: CGFloat = 200
        let rowHeight: CGFloat = ((selfHeight - (2 * textFieldInset)) - (CGFloat(titleText.count + 1) * interRowSpace)) / CGFloat(titleText.count)
        
        var x = interColSpace
        var y = interRowSpace
        for i in 0..<titleText.count {
            let label = UILabel()
            //label.backgroundColor = .green
            label.frame = CGRect(
                x: x,
                y: y,
                width: rowWidthForLabel,
                height: rowHeight
            )
            label.text = titleText[i]
            containerView.addSubview(label)
            
            x = x + interColSpace + rowWidthForLabel
            if i == titleText.count - 1 {
                let dropDownView = DropDownCustomView(
                    frame: CGRect(
                        origin: CGPoint(x: x, y: y),
                        size: CGSize(width: rowWidthForTextView, height: rowHeight)
                    ),
                    dropDownList: ["fixed", "negotiable"],
                    viewController: parentViewController ?? UIViewController()
                )
                dropDownView.clipsToBounds = true
                dropDownView.layer.cornerRadius = 10
                containerView.addSubview(dropDownView)
            } else {
                let textField = UITextField()
                //textField.backgroundColor = .red
                textField.frame = CGRect(
                    x: x,
                    y: y,
                    width: rowWidthForTextView,
                    height: rowHeight
                )
                //textField.text = titleText[i]
                //textField.isEnabled = false
                textField.placeholder = placeHolderText[i]
                textField.delegate = self
                containerView.addSubview(textField)
                textFieldList.append(textField)
            }
            y = y + rowHeight + interRowSpace
            x = interColSpace
        }
    }
}

extension PriceDetailsCustomView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

import UIKit

class DropDownCustomView: UIView {
    private var dropDownList: [String] = []
    private var dropDownAction: [() -> Void] = []
    private var curSelected: String?
    weak var parentViewController: UIViewController?
    
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private let videoInternalSpace: CGFloat = 10
    private var mainButton = UIButton()
    private var dropDownView: UIView = UIView()
    
    var isEnabled: Bool = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, dropDownList: [String], dropDownAction: [() -> Void] = [],viewController: UIViewController) {
        self.init(frame: frame)
        self.dropDownList = dropDownList
        self.dropDownAction = dropDownAction
        self.parentViewController = viewController
    }

    convenience init(dropDownList: [String], dropDownAction: [() -> Void] = [], viewController: UIViewController) {
        self.init(frame: .zero)
        self.dropDownList = dropDownList
        self.dropDownAction = dropDownAction
        self.parentViewController = viewController
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func draw(_ rect: CGRect) {
        selfWidth = rect.width
        selfHeight = rect.height

        //self.backgroundColor = .blue
        
        configureTDropDownView()
    }
    
    private func configureTDropDownView() {
        let containerView = UIView()
        containerView.frame = CGRect(
            origin: .zero,
            size: CGSize(width: selfWidth, height: selfHeight)
        )
        self.addSubview(containerView)
        
        mainButton.frame = containerView.bounds
        if dropDownList.count >= 1 {
            curSelected = dropDownList.remove(at: 0)
        }
        mainButton.setTitle(curSelected, for: .normal)
        mainButton.setTitleColor(.white, for: .normal)
        mainButton.setTitleColor(.black, for: .highlighted)
        mainButton.backgroundColor = .blue
        mainButton.addTarget(self, action: #selector(tappedOnMenuLabel), for: .touchUpInside)
        containerView.addSubview(mainButton)
    }
    
    @objc private func tappedOnMenuLabel() {
        guard isEnabled else { return }
        showDropDownList()
    }
    
    private func showDropDownList() {
        let itemWidth: CGFloat = selfWidth
        let itemHeight: CGFloat = selfHeight
        guard dropDownList.count > 0 else { return }
        // Need to remove previous view
        dropDownView.removeFromSuperview()
        dropDownView = UIView()
        dropDownView.frame = CGRect(
            origin: .zero,
            size: CGSize(
                width: itemWidth,
                height: itemHeight * CGFloat(dropDownList.count)
            )
        )
        dropDownView.layer.cornerRadius = 10
        dropDownView.clipsToBounds = true
        
        var y: CGFloat = 0
        for i in 0..<dropDownList.count {
            let button = UIButton()
            button.frame = CGRect(
                x: 0,
                y: y,
                width: itemWidth,
                height: itemHeight
            )
            button.setTitle(dropDownList[i], for: .normal)
            button.backgroundColor = .blue
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.black, for: .highlighted)
            //button.layer.borderWidth = 1
            dropDownView.addSubview(button)
            button.addTarget(self, action: #selector(tappedOnDropDownLabel), for: .touchUpInside)
            y = y + itemHeight
        }
        
        let lowerPoint = self.convert(
            CGPoint(x: 0, y: selfHeight),
            to: parentViewController?.view ?? self
        )
        
        if lowerPoint.y + (CGFloat(dropDownList.count) * itemHeight) <= (parentViewController?.view.frame.height ?? 0.0) {
            dropDownView.frame.origin = lowerPoint
        } else {
            dropDownView.frame.origin = CGPoint(
                x: lowerPoint.x,
                y: lowerPoint.y - selfHeight - (CGFloat(dropDownList.count) * itemHeight)
            )
        }
        parentViewController?.view.addSubview(dropDownView)
    }
    
//    @objc private func tappedOnDropDownLabel(sender: UIButton) {
//        let selectedIdx: Int = Int(sender.frame.minY / sender.frame.height)
//        let lastSelected = curSelected
//        curSelected = dropDownList.remove(at: selectedIdx)
//        mainButton.setTitle(curSelected, for: .normal)
//        if let unwrappedLastSelected = lastSelected {
//            dropDownList.append(unwrappedLastSelected)
//        }
//        dropDownView.removeFromSuperview()
//        //dropDownView.isHidden = true
//    }
    @objc private func tappedOnDropDownLabel(sender: UIButton) {
        let selectedIdx: Int = Int(sender.frame.minY / sender.frame.height)
        guard dropDownAction.count > selectedIdx else { return }
        dropDownAction[selectedIdx]()
        dropDownView.removeFromSuperview()
    }
}

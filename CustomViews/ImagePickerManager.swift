import UIKit

class ImagePickerManager: NSObject {
    private let selfWidth: CGFloat
    private let selfHeight: CGFloat
    private let frame: CGRect
    
    weak var parentViewController: UIViewController?
    
    init(rect: CGRect, viewController: UIViewController) {
        self.frame = rect
        self.parentViewController = viewController
        selfWidth = rect.width
        selfHeight = rect.height
    }
    
    func getView() -> UIView {
        let insetSize: CGFloat = 10
        let labelSize: CGFloat = 30
        
        let view = UIView()
        view.frame = frame
        view.backgroundColor = .white
        
        let addLabel = UIButton(type: .system)
        addLabel.frame = CGRect(
            x: insetSize,
            y: selfHeight - labelSize - insetSize,
            width: labelSize,
            height: labelSize
        )
        addLabel.clipsToBounds = true
        addLabel.layer.cornerRadius = 10
        addLabel.setTitle("+", for: .normal)
        addLabel.titleLabel?.font = .systemFont(ofSize: 20)
        addLabel.setTitleColor(.white, for: .normal)
        addLabel.backgroundColor = UIColor(hex: "4a7c59")
        view.addSubview(addLabel)
        
        addLabel.addTarget(self, action: #selector(tappedOnAddLabel(_ :)), for: .touchUpInside)
        
        let removeLabel = UIButton(type: .system)
        removeLabel.frame = CGRect(
            x: insetSize + insetSize + labelSize,
            y: selfHeight - labelSize - insetSize,
            width: labelSize,
            height: labelSize
        )
        removeLabel.clipsToBounds = true
        removeLabel.layer.cornerRadius = 10
        removeLabel.setTitle("-", for: .normal)
        removeLabel.setTitleColor(.white, for: .normal)
        removeLabel.backgroundColor = UIColor(hex: "8c2f39")
        view.addSubview(removeLabel)
        
        removeLabel.addTarget(self, action: #selector(tappedOnRemoveLabel(_ :)), for: .touchUpInside)
        
        return view
    }
    
    @objc private func tappedOnAddLabel(_ gesture: UITapGestureRecognizer) {
        print("tappedAction for add label")
        showAlertView()
    }
    
    @objc private func tappedOnRemoveLabel(_ gesture: UITapGestureRecognizer) {
        print("tappedAction for remove label")
        NotificationCenter.default.post(
            name: Notification.Name.imageDeletedIdxNotifi,
            object: nil
        )
    }
    
    func showAlertView() {
        let actionController = UIAlertController(
            title: "CHOOSE A SOURCE",
            message: "",
            preferredStyle: .actionSheet
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Camera",
                style: .default,
                handler: { _ in
                    self.showImagePickerControllerForCamera()
                }
            )
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Photo Library",
                style: .default,
                handler: { _ in
                    self.showImagePickerControllerForLibrary()
                }
            )
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        parentViewController?.present(actionController, animated: true)
    }
}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerControllerForCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        parentViewController?.present(imagePickerController, animated: true)
    }
    
    func showImagePickerControllerForLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        //imagePickerController.allowsEditing = true
        GlobalUITask.showSpinner(viewController: parentViewController ?? UIViewController())
        parentViewController?.present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            NotificationCenter.default.post(
                name: Notification.Name.imgSelectedNotifi,
                object: nil,
                userInfo: [Notification.Name.imgSelectedNotifi: editedImageUrl]
            )
        }
        GlobalUITask.removeSpinner(viewController: parentViewController ?? UIViewController())
        parentViewController?.dismiss(animated: true, completion: nil)
    }
}

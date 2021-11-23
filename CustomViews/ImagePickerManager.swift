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
        let labelSize: CGFloat = 50
        
        let view = UIView()
        view.frame = frame
        view.backgroundColor = .white
        
        let addLabel = UILabel()
        addLabel.frame = CGRect(
            x: insetSize,
            y: insetSize,
            width: labelSize,
            height: labelSize
        )
        addLabel.clipsToBounds = true
        addLabel.layer.cornerRadius = labelSize / 2
        addLabel.text = "ADD"
        addLabel.textColor = .green
        addLabel.textAlignment = .center
        addLabel.backgroundColor = .gray
        view.addSubview(addLabel)
        
        let tapForAddLabel = UITapGestureRecognizer(target: self, action: #selector(tappedOnAddLabel(_ :)))
        addLabel.isUserInteractionEnabled = true
        addLabel.addGestureRecognizer(tapForAddLabel)
        
        let removeLabel = UILabel()
        removeLabel.frame = CGRect(
            x: insetSize + insetSize + labelSize,
            y: insetSize,
            width: labelSize,
            height: labelSize
        )
        removeLabel.clipsToBounds = true
        removeLabel.layer.cornerRadius = labelSize / 2
        removeLabel.text = "REM"
        removeLabel.textColor = .red
        removeLabel.textAlignment = .center
        removeLabel.backgroundColor = .gray
        view.addSubview(removeLabel)
        
        let tapForRemoveLabel = UITapGestureRecognizer(target: self, action: #selector(tappedOnRemoveLabel(_ :)))
        removeLabel.isUserInteractionEnabled = true
        removeLabel.addGestureRecognizer(tapForRemoveLabel)
        
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
        parentViewController?.present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            NotificationCenter.default.post(
                name: Notification.Name.imgSelectedNotifi,
                object: nil,
                userInfo: [Notification.Name.imgSelectedNotifi: editedImage]
            )
        }
        parentViewController?.dismiss(animated: true, completion: nil)
    }
}
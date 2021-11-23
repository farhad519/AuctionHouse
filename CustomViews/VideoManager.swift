import MobileCoreServices
import UIKit

class VideoManager: NSObject {
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
        
        let tapForRemoveLabel = UITapGestureRecognizer(target: self, action: #selector(tappedOnAddLabel(_ :)))
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
        showAlertView()
    }
    
    func showAlertView() {
        let actionController = UIAlertController(
            title: "CHOOSE A SOURCE",
            message: "",
            preferredStyle: .actionSheet
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Record by camera",
                style: .default,
                handler: { _ in
                    self.showImagePickerControllerForCamera()
                }
            )
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Doc Library",
                style: .default,
                handler: { _ in
                    self.showImagePickerControllerForDocuments()
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

extension VideoManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showImagePickerControllerForCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return
        }
        
        guard (UIImagePickerController.availableCaptureModes(for: .rear) != nil) else {
            return
        }

        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        imagePickerController.allowsEditing = false
        parentViewController?.present(imagePickerController, animated: true)
    }
    
    func showImagePickerControllerForDocuments() {
        let picker = UIDocumentPickerViewController(forExporting: [], asCopy: true)
        parentViewController?.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] {
            NotificationCenter.default.post(
                name: Notification.Name.videoUrlNotifi,
                object: nil,
                userInfo: [Notification.Name.videoUrlNotifi: videoUrl]
            )
        }
        parentViewController?.dismiss(animated: true, completion: nil)
    }
}

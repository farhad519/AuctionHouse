import UIKit

extension Notification.Name {
    static let imgSelectedNotifi = Notification.Name("ImageSelectedNotification")
    static let videoUrlNotifi = Notification.Name("VideoUrlNotification")
    static let imageDeletedIdxNotifi = Notification.Name("ImageDeletedIdxNotifi")
}

class SellDetailsViewController: UIViewController {
    private let imageCellHeight: CGFloat = 200
    private let headerHeight: CGFloat = 70
    private let postButtonFooterHeight: CGFloat = 50
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private var tableView = UITableView(frame: .zero, style: .grouped)
    private var editOption: Bool = false
    private let imageCellId = "ImageCellForCollectionView"
    private let priceDetailsTableViewCellId = "PriceDetailsCell"
    private let textViewCellId = "TextViewCell"
    
    private var videoManager: VideoManager?
    private var imagePickerManager: ImagePickerManager?
    
    private var imageSwiperCustomView: ImageSwiperCustomView?
    private var videoPlayerCustomView: VideoPlayerCustomView?
    
    private var viewModel: SellDetailsViewModel!
    
    private var editButton: UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editTapped)
        )
    }
    
    private var saveButton: UIBarButtonItem {
        UIBarButtonItem(
            barButtonSystemItem: .save,
            target: self,
            action: #selector(editTapped)
        )
    }
    
    static func makeViewController(
        viewType: SellDetailsViewType,
        imageUrlCoupleList: [ImageUrlCouple] = [],
        fireAuctionItem: FireAuctionItem? = nil
    ) -> SellDetailsViewController {
        let vc = SellDetailsViewController()
        guard
            let fireAuctionItem = fireAuctionItem else {
            vc.viewModel = SellDetailsViewModel(viewType: .forCreate)
            return vc
        }
        if viewType == SellDetailsViewType.forCreate {
            vc.viewModel = SellDetailsViewModel(viewType: viewType)
        } else {
            vc.viewModel = SellDetailsViewModel(
                viewType: viewType,
                imageUrlCoupleList: imageUrlCoupleList,
                fireAuctionItem: fireAuctionItem
            )
        }
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selfWidth = self.view.frame.width
        selfHeight = self.view.frame.height
        
        //navigationItem.title = "Sell details"
        if viewModel.viewType != SellDetailsViewType.forBid {
            navigationItem.rightBarButtonItem = editButton
        }
        
        configureTableView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.imageSelectionAction(_:)),
            name: Notification.Name.imgSelectedNotifi,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.videoSelectionAction(_:)),
            name: Notification.Name.videoUrlNotifi,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.imageDeletionAction(_:)),
            name: Notification.Name.imageDeletedIdxNotifi,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = .black
    }
    
    @objc private func editTapped() {
        if editOption {
            editOption = false
            navigationItem.rightBarButtonItem = editButton
            collectEditedInfo()
        } else {
            editOption = true
            navigationItem.rightBarButtonItem = saveButton
        }
        tableView.reloadData()
    }

    @objc private func imageSelectionAction(_ notification: NSNotification) {
        if
            let imageUrl = notification.userInfo?[Notification.Name.imgSelectedNotifi] as? URL,
            let data = try? Data(contentsOf: imageUrl),
            let image = UIImage(data: data)
        {
            viewModel.imageUrlCoupleList.append(
                ImageUrlCouple(image: image, url: imageUrl, isFromCloud: false)
            )
        }
        tableView.reloadData()
    }
    
    @objc private func videoSelectionAction(_ notification: NSNotification) {
        if let videoUrl = notification.userInfo?[Notification.Name.videoUrlNotifi] as? URL {
            viewModel.videoList = [videoUrl]
//            let data = try? Data(contentsOf: videoUrl)
//            print(data?.count)
//            UserDefaults.standard.set(data, forKey: "testVideoSave")
        }
        tableView.reloadData()
    }
    
    @objc private func imageDeletionAction(_ notification: NSNotification) {
        guard
            let curPageIdx = imageSwiperCustomView?.curImagePage,
            curPageIdx < viewModel.imageUrlCoupleList.count else { return }
        viewModel.imageUrlCoupleList.remove(at: curPageIdx)
        tableView.reloadData()
    }
    
    @objc private func postButtonAction(sender: UIButton) {
        print("post button tapped.")
        guard editOption == false else { return }
        
        if let errorString = viewModel.isAnyFieldEmpty() {
            showFieldEmptyAlert(errorString: errorString)
            return
        }
        
        GlobalUITask.showSpinner(viewController: self)
        viewModel.saveDataToFireStore() { [weak self] resultString in
            //DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            GlobalUITask.removeSpinner(viewController: self ?? UIViewController())
            Toast.show(message: resultString, controller: self ?? UIViewController())
            //}
        }
    }
    
    private func showFieldEmptyAlert(errorString: String) {
        let actionController = UIAlertController(
            title: "",
            message: errorString,
            preferredStyle: .alert
        )
        
        actionController.addAction(
            UIAlertAction(
                title: "Ok",
                style: .default,
                handler: nil
            )
        )
        
        present(actionController, animated: true)
    }
    
    private func collectEditedInfo() {
        let textViewCell = tableView.cellForRow(at: IndexPath(item: 0, section: 2)) as? TextViewCell
        viewModel.editedValue.description = textViewCell?.descriptionTextView.textColor == .black
        ? (textViewCell?.descriptionTextView.text ?? "")
        : ""
        let priceDetailsCell = tableView.cellForRow(at: IndexPath(item: 0, section: 3)) as? PriceDetailsCell
        viewModel.editedValue.title = priceDetailsCell?.titleField.text ?? ""
        viewModel.editedValue.type = priceDetailsCell?.typeField.text ?? ""
        viewModel.editedValue.price = priceDetailsCell?.priceField.text ?? ""
        viewModel.editedValue.negotiable = priceDetailsCell?.negotiableField.text ?? ""
    }

    private func configureTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = CGRect(
            origin: .zero,
            size: self.view.frame.size
        )
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: imageCellId)
        let bundle = Bundle(for: type(of: self))
        tableView.register(UINib(nibName: "PriceDetailsCell", bundle: bundle), forCellReuseIdentifier: priceDetailsTableViewCellId)
        tableView.register(UINib(nibName: "TextViewCell", bundle: bundle), forCellReuseIdentifier: textViewCellId)
    }
}

extension SellDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellId, for: indexPath)
            imageSwiperCustomView?.removeFromSuperview()
            imageSwiperCustomView = ImageSwiperCustomView(
                frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: selfWidth, height: imageCellHeight)
                ),
                imageList: viewModel.imageUrlCoupleList.map { $0.image }
            )
            cell.addSubview(imageSwiperCustomView ?? UIView())
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: imageCellId, for: indexPath)
            videoPlayerCustomView?.removeFromSuperview()
            videoPlayerCustomView = VideoPlayerCustomView(
                frame: CGRect(
                    origin: .zero,
                    size: CGSize(width: selfWidth, height: imageCellHeight)
                ),
                videoList: viewModel.videoList,
                viewController: self
            )
            cell.addSubview(videoPlayerCustomView ?? UIView())
            cell.selectionStyle = .none
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: textViewCellId, for: indexPath) as! TextViewCell
            //cell.descriptionTextView.delegate = viewModel.descriptionTextViewPlaceHolder
            cell.descriptionTextView.text = viewModel.descriptionTextViewPlaceHolder.placeHolderString
            cell.descriptionTextView.textColor = .lightGray
            cell.selectionStyle = .none
            
            if viewModel.getEditedText(for: .description) != "" {
                cell.descriptionTextView.text = viewModel.getEditedText(for: .description)
                cell.descriptionTextView.textColor = .black
            }
            
            if editOption {
                cell.descriptionTextView.isEditable = true
            } else {
                cell.descriptionTextView.isEditable = false
            }
            
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: priceDetailsTableViewCellId, for: indexPath) as! PriceDetailsCell
            
            cell.selectionStyle = .none
            
            cell.titleLabel.text = "title"
            cell.typeLabel.text = "type"
            cell.priceLabel.text = "price"
            cell.negotiableLabel.text = "negotiable"
            
            cell.titleField.placeholder = "title for sell details"
            cell.typeField.placeholder = "write type eg: book, iPhone, car etc"
            cell.priceField.placeholder = "write price in dollar"
            cell.negotiableField.placeholder = "yes/no"
            
            cell.titleField.text = viewModel.getEditedText(for: .title)
            cell.typeField.text = viewModel.getEditedText(for: .type)
            cell.priceField.text = viewModel.getEditedText(for: .price)
            cell.negotiableField.text = viewModel.getEditedText(for: .negotiable)
            
            if editOption {
                cell.titleField.isEnabled = true
                cell.typeField.isEnabled = true
                cell.priceField.isEnabled = true
                cell.negotiableField.isEnabled = true
            } else {
                cell.titleField.isEnabled = false
                cell.typeField.isEnabled = false
                cell.priceField.isEnabled = false
                cell.negotiableField.isEnabled = false
            }

            return cell
        }
        return UITableViewCell()
    }
}

extension SellDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //imagePickerCustomView?.showAlertView()
        //let vvv = ContactListViewController()
        //vvv.modalPresentationStyle = .fullScreen
        //self.present(vvv, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        imageCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard editOption == true else {
            return 30
        }
        return headerHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard editOption == true else {
            let headerView = UIView()
            return headerView
        }
        if section == 1 {
            let videoManager = VideoManager(
                rect: CGRect(
                    origin: .zero,
                    size: CGSize(width: selfWidth, height: headerHeight)
                ),
                viewController: self
            )
            self.videoManager = videoManager
            return videoManager.getView()
        } else if section == 0 {
            let imagePickerManager = ImagePickerManager(
                rect: CGRect(
                    origin: .zero,
                    size: CGSize(width: selfWidth, height: headerHeight)
                ),
                viewController: self
            )
            self.imagePickerManager = imagePickerManager
            return imagePickerManager.getView()
        } else {
            let view = UIView()
            //view.backgroundColor = UIColor(hex: "#67aebe", alpha: 1)
            view.backgroundColor = .white
            return view
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return postButtonFooterHeight
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .white
        
        guard section == 3 else {
            return view
        }
        
        let postButton = UIButton()
        postButton.frame = CGRect(
            x: 5,
            y: 5,
            width: selfWidth - 10,
            height: postButtonFooterHeight - 10
        )
        postButton.backgroundColor = .blue
        postButton.layer.cornerRadius = 10
        postButton.setTitle(viewModel.buttonTitle, for: .normal)
        postButton.setTitleColor(.gray, for: .highlighted)
        postButton.addTarget(
            self,
            action: #selector(postButtonAction),
            for: .touchUpInside
        )
        view.addSubview(postButton)
        
        if viewModel.viewType == SellDetailsViewType.forBid {
            postButton.backgroundColor = .red
        }
        
        return view
    }
}

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var cString: String = hex.trimmingCharacters(in: (NSCharacterSet.whitespacesAndNewlines as NSCharacterSet) as CharacterSet).uppercased()

        if cString.hasPrefix("#") {
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 1)...])
        }

        var flag = true
        let hexChars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]

        for character in cString {
            if !hexChars.contains(String(character)) {
                flag = false
            }
        }

        flag = flag && cString.count == 6

        guard flag else {
            self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
            return
        }

        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        let cRed = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let cGreen = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let cBlue = CGFloat(rgbValue & 0x0000FF) / 255.0

        self.init(red: cRed, green: cGreen, blue: cBlue, alpha: alpha)
    }
}

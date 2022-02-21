import UIKit

class DashboardViewController: UIViewController {
    var selfWidth: CGFloat = 0.0
    var selfHight: CGFloat = 0.0
    let sellButtonSize: CGSize = CGSize(width: 200, height: 50)
    let buyButtonSize: CGSize = CGSize(width: 200, height: 50)
    let menuViewSize: CGSize = CGSize(width: 160, height: 40)
    let swipeViewHeight: CGFloat = 200
    let referenceHeight: CGFloat = 150
    
    let groundLevelColor = UIColor(hex: "03396c")
    let firstLevelColor = UIColor(hex: "005b96")
    
    let containerView = UIView()
    let swipeView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        selfWidth = self.view.frame.width
        selfHight = self.view.frame.height
        setupNavigationBar()
        setupMainView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "asd asd asd"
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = groundLevelColor
        navigationController?.navigationBar.backgroundColor = groundLevelColor
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func setupMainView() {
        setupContainerView()
        setupMenuView()
        setupSwipeView()
        setupSellAndBuyButton()
    }
    
    private func setupContainerView() {
        self.view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        containerView.backgroundColor = groundLevelColor
    }
    
    private func setupMenuView() {
        let menuView = DropDownCustomView(
            dropDownList: [
                "Sell",
                "Buy",
                "Messages",
                "My Sell List",
                "My Bid List"
            ],
            color: firstLevelColor,
            dropDownAction: [
                {
                    self.navigationController?.pushViewController(
                        SellDetailsViewController.makeViewController(viewType: .forCreate),
                        animated: true
                    )
                },
                {
                    self.navigationController?.pushViewController(
                        AuctionListViewController.makeViewController(auctionListViewType: .auctionListView),
                        animated: true
                    )
                },
                {
                    self.navigationController?.pushViewController(
                        ContactListViewController.makeViewController(),
                        animated: true
                    )
                },
                {
                    self.navigationController?.pushViewController(
                        AuctionListViewController.makeViewController(auctionListViewType: .createdView),
                        animated: true
                    )
                },
                {
                    self.navigationController?.pushViewController(
                        AuctionListViewController.makeViewController(auctionListViewType: .bidListView),
                        animated: true
                    )
                }
            ],
            viewController: self
        )
        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.frame = CGRect(
            x: selfWidth - menuViewSize.width - 10,
            y: 10,
            width: menuViewSize.width,
            height: menuViewSize.height
        )
        menuView.layer.cornerRadius = 10
        menuView.backgroundColor = firstLevelColor
        menuView.clipsToBounds = true
        containerView.addSubview(menuView)
    }
    
    private func setupSwipeView() {
        swipeView.frame = CGRect(
            x: 0,
            y: referenceHeight,
            width: selfWidth,
            height: swipeViewHeight
        )
        let imageSwiperCustomView = ImageSwiperCustomView(
            frame: CGRect(
                origin: .zero,
                size: CGSize(width: selfWidth, height: swipeViewHeight)
            ),
            imageList: [UIImage(named: "img1")!, UIImage(named: "img2")!, UIImage(named: "img3")!],
            groundLevelColor: .white,
            firstLevelColor: .white,
            secondLevelColor: .white
        )
        swipeView.addSubview(imageSwiperCustomView)
        //swipeView.backgroundColor = .cyan
        containerView.addSubview(swipeView)
    }
    
    private func setupSellAndBuyButton() {
        let sellButton = UIButton(type: .system)
        containerView.addSubview(sellButton)
        sellButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sellButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sellButton.topAnchor.constraint(equalTo: swipeView.bottomAnchor, constant: 100),
            sellButton.heightAnchor.constraint(equalToConstant: sellButtonSize.height),
            sellButton.widthAnchor.constraint(equalToConstant: sellButtonSize.width)
        ])
        sellButton.setTitleColor(.white, for: .normal)
        sellButton.layer.cornerRadius = 10
        sellButton.backgroundColor = firstLevelColor
        sellButton.setTitle("Sell", for: .normal)
        sellButton.addTarget(self, action: #selector(sellButtonAction), for: .touchUpInside)
        
        let buyButton = UIButton(type: .system)
        containerView.addSubview(buyButton)
        buyButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buyButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            buyButton.topAnchor.constraint(equalTo: sellButton.bottomAnchor, constant: 20),
            buyButton.heightAnchor.constraint(equalToConstant: buyButtonSize.height),
            buyButton.widthAnchor.constraint(equalToConstant: buyButtonSize.width)
        ])
        buyButton.setTitleColor(.white, for: .normal)
        buyButton.layer.cornerRadius = 10
        buyButton.backgroundColor = firstLevelColor
        buyButton.setTitle("Buy", for: .normal)
        buyButton.addTarget(self, action: #selector(buyButtonAction), for: .touchUpInside)
    }
    
    @objc private func sellButtonAction() {
        self.navigationController?.pushViewController(
            SellDetailsViewController.makeViewController(viewType: .forCreate),
            animated: true
        )
    }
    
    @objc private func buyButtonAction() {
        self.navigationController?.pushViewController(
            AuctionListViewController.makeViewController(auctionListViewType: .auctionListView),
            animated: true
        )
    }
}

import UIKit

class ImageSwiperCustomView: UIView {
    private var imageList: [UIImage] = []
    private let scrollView = UIScrollView()
    
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private let imageInternalSpace: CGFloat = 10
    
    private var pageController: UIPageControl = UIPageControl()
    private let pageControllerHeight: CGFloat = 20
    
    private var lastPage = 0
    
    var curImagePage: Int { pageController.currentPage }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, imageList: [UIImage]) {
        self.init(frame: frame)
        self.imageList = imageList
    }

    convenience init(imageList: [UIImage]) {
        self.init(frame: .zero)
        self.imageList = imageList
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func draw(_ rect: CGRect) {
        selfWidth = rect.width
        selfHeight = rect.height
        scrollView.delegate = self
        
        configurePageControllerView()
        configureScrollView()
        self.backgroundColor = .blue
    }
    
    private func configurePageControllerView() {
        pageController.numberOfPages = imageList.count
        pageController.currentPage = 0
        lastPage = 0
        pageController.frame = CGRect(
            x: 0,
            y: selfHeight - pageControllerHeight,
            width: selfWidth,
            height: pageControllerHeight
        )
        pageController.backgroundColor = .white
        pageController.pageIndicatorTintColor = .gray
        pageController.currentPageIndicatorTintColor = .black
        pageController.addTarget(
            self,
            action: #selector(pageControlTapHandler(sender:)),
            for: .valueChanged
        )
        self.addSubview(pageController)
    }
    
    @objc func pageControlTapHandler(sender:UIPageControl) {
        scrollView.setContentOffset(
            CGPoint(
                x: CGFloat(sender.currentPage) * selfWidth,
                y: 0
            ),
            animated: true
        )
        lastPage = sender.currentPage
    }
    
    private func configureScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.frame = CGRect(
            origin: .zero,
            size: CGSize(width: selfWidth, height: selfHeight - pageControllerHeight)
        )
        self.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(
            width: CGFloat(imageList.count) * selfWidth,
            height: selfHeight
        )
        
        let imageViewWidth = selfWidth - (2 * imageInternalSpace)
        let imageViewHeight = selfHeight - (imageInternalSpace) - pageControllerHeight
        var x = imageInternalSpace
        let y = imageInternalSpace
        for i in 0..<imageList.count {
            let imageView = UIImageView(
                frame: CGRect(
                    x: x,
                    y: y,
                    width: imageViewWidth,
                    height: imageViewHeight
                )
            )
            imageView.image = imageList[i]
            imageView.layer.cornerRadius = selfHeight / 10
            imageView.clipsToBounds = true
            scrollView.addSubview(imageView)
            x = x + selfWidth
        }
        
        if imageList.count == 0 {
            let emptyView = UIView(
                frame: CGRect(
                    x: x,
                    y: y,
                    width: imageViewWidth,
                    height: imageViewHeight
                )
            )
            emptyView.backgroundColor = .white
            emptyView.layer.cornerRadius = selfHeight / 10
            emptyView.clipsToBounds = true
            //emptyView.layer.borderWidth = 0.2
            scrollView.addSubview(emptyView)
            
            let labelSize: CGFloat = 100
            let label = UILabel()
            emptyView.addSubview(label)
            label.frame = CGRect(
                x: (imageViewWidth / 2) - (labelSize / 2),
                y: (imageViewHeight / 2) - (labelSize / 2),
                width: labelSize,
                height: labelSize
            )
            label.text = "Image"
            label.textColor = .white
            label.backgroundColor = .gray
            label.textAlignment = .center
            label.layer.cornerRadius = 50
            label.clipsToBounds = true
        }

        scrollView.backgroundColor = .white
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
    }
}

extension ImageSwiperCustomView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            scrollView.contentOffset.y = 0
        }
        pageController.currentPage = Int(scrollView.contentOffset.x / selfWidth)
    }
}

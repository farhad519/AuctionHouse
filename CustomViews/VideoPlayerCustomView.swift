import AVFoundation
import AVKit
import UIKit

class VideoPlayerCustomView: UIView {
    private var videoList: [URL] = []
    weak var parentViewController: UIViewController?
    
    private var selfWidth: CGFloat = 0.0
    private var selfHeight: CGFloat = 0.0
    private let videoInternalSpace: CGFloat = 10
    
    private let upperView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, videoList: [URL], viewController: UIViewController) {
        self.init(frame: frame)
        self.videoList = videoList
        self.parentViewController = viewController
    }

    convenience init(videoList: [URL], viewController: UIViewController) {
        self.init(frame: .zero)
        self.videoList = videoList
        self.parentViewController = viewController
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func draw(_ rect: CGRect) {
        selfWidth = rect.width
        selfHeight = rect.height

        //self.backgroundColor = .blue
        
        configureVideoPlayerView()
    }
    
//    func getLastUrl() -> URL {
//        let data = UserDefaults.standard.data(forKey: "testVideoSave")
//        print(data?.count)
//        let directory = FileManager.default.temporaryDirectory
//        let fileName = "\(NSUUID().uuidString).mov"
//        let url = directory.appendingPathComponent(fileName)
//        do {
//            try data?.write(to: url)
//        } catch {
//            print("Error creating temporary file: \(error)")
//        }
//        return url
//    }
    
    func configureVideoPlayerView() {
        //videoList.append(getLastUrl())
        guard let videoUrl = videoList.first else {
            let view = UIView()
            view.frame = CGRect(
                x: videoInternalSpace,
                y: videoInternalSpace,
                width: selfWidth - (2 * videoInternalSpace),
                height: selfHeight - (2 * videoInternalSpace)
            )
            view.layer.cornerRadius = selfHeight / 10
            //view.layer.borderWidth = 0.2
            self.addSubview(view)
            
            let label = UILabel()
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.widthAnchor.constraint(equalToConstant: 100),
                label.heightAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
            label.text = "Video"
            label.textColor = .white
            label.backgroundColor = .gray
            label.textAlignment = .center
            label.layer.cornerRadius = 50
            label.clipsToBounds = true
            return
        }
        let player = AVPlayer(url: videoUrl)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = CGRect(
            x: videoInternalSpace,
            y: videoInternalSpace,
            width: selfWidth - (2 * videoInternalSpace),
            height: selfHeight - (2 * videoInternalSpace)
        )
        playerLayer.videoGravity = .resizeAspect
        playerLayer.backgroundColor = UIColor.black.cgColor
        playerLayer.cornerRadius = selfHeight / 10
        //playerLayer.borderWidth = 1
        //playerLayer.borderColor = UIColor.black.cgColor
        self.layer.addSublayer(playerLayer)
        
        upperView.frame = CGRect(
            x: videoInternalSpace,
            y: videoInternalSpace,
            width: selfWidth - (2 * videoInternalSpace),
            height: selfHeight - (2 * videoInternalSpace)
        )
        self.addSubview(upperView)
        upperView.backgroundColor = .clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedOnUpperView(_ :)))
        upperView.isUserInteractionEnabled = true
        upperView.addGestureRecognizer(tap)
    }
    
    @objc private func tappedOnUpperView(_ gesture: UITapGestureRecognizer) {
        print("tappedOnUpperView")
        guard let videoUrl = videoList.first else {
            return
        }
        let player = AVPlayer(url: videoUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        parentViewController?.present(playerViewController, animated: true)
    }
}

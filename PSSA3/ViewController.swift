import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    struct Photo {
        var imageName: String
    }
    
    var photoList = [
        Photo(imageName: "Scrolle1"),
        Photo(imageName: "Scrolle2"),
        Photo(imageName: "Scrolle3")
    ]
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var currentIndex = 0
    var scrollView: UIScrollView!
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground(name: "BackGroundPicture")
        menuButton.imageInsets = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: -20)
        
        
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 160, width: self.view.frame.size.width, height: 250))
        self.scrollView.contentSize = CGSize(width: self.view.frame.size.width * CGFloat(photoList.count), height: self.scrollView.frame.size.height)
        self.scrollView.contentOffset = CGPoint(x: self.view.frame.size.width, y: 0)
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        self.setUpImageView()
        
        startAutoScroll()
    }
        
    func createImageView(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, image: Photo) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
        let image = UIImage(named: image.imageName)
        imageView.image = image
        return imageView
    }
    
    func setUpImageView() {
        for i in 0 ..< self.photoList.count {
            let photoItem = self.photoList[i]
            let imageView = createImageView(x: CGFloat(i) * self.view.frame.size.width, y: 0, width: self.view.frame.size.width, height: self.scrollView.frame.size.height, image: photoItem)
            self.scrollView.addSubview(imageView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = self.scrollView.contentOffset.x
        
        if (offsetX > self.scrollView.frame.size.width * 1.5) {
            let sortedPhoto = self.photoList[0]
            self.photoList.append(sortedPhoto)
            self.photoList.removeFirst()
            self.setUpImageView()
            self.scrollView.contentOffset.x -= self.scrollView.frame.size.width
        }
        
        if (offsetX < self.scrollView.frame.size.width * 0.5) {
            let sortedPhoto = self.photoList[photoList.count - 1]
            self.photoList.insert(sortedPhoto, at: 0)
            self.photoList.removeLast()
            self.setUpImageView()
            self.scrollView.contentOffset.x += self.scrollView.frame.size.width
        }
    }
    
    func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    func startAutoScroll() {
        guard timer == nil else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(scrollToNextPage), userInfo: nil, repeats: true)
    }
    
    @objc func scrollToNextPage() {
        let nextPage = (currentIndex + 1) % photoList.count
        let contentOffset = CGPoint(x: self.scrollView.frame.size.width * CGFloat(nextPage + 1), y: 0)
        self.scrollView.setContentOffset(contentOffset, animated: true)
        currentIndex = nextPage
    }
}

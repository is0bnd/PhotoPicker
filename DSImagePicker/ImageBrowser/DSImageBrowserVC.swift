//
//  DSImageBrowserVC.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/29.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

//MARK: - 图片浏览器VC
class ImageBrowerController: UICollectionViewController {
    
    private var imageSources = [UIImageViewImageSource]()
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK: - 跳转方法
extension ImageBrowerController {
    static func showBrower(with images: [UIImageViewImageSource], sourceVC: UIViewController) {
        let browserVC = ImageBrowerController()
        browserVC.imageSources = images
        sourceVC.show(browserVC, sender: nil)
    }
}

//MARK: - 生命周期
extension ImageBrowerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        config()
    }
    
    private func config() {
        title = "1/\(imageSources.count)"
        configCollectionView()
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapView))
    }
    
    private func configCollectionView() {
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.scrollDirection = .horizontal
        layout.itemSize = UIScreen.main.bounds.size
        layout.minimumLineSpacing = 32
        layout.minimumInteritemSpacing = 32
        collectionView?.collectionViewLayout = layout
        collectionView.decelerationRate = .fast
        collectionView.backgroundColor = .white
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        self.collectionView!.register(ImageBrowerCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    @objc private func tapView() {
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(!navigationController.navigationBar.isHidden, animated: true)
        }
    }
}

//MARK: - 设置CollectionView 滚动停止位置
extension ImageBrowerController {
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let offset = scrollView.contentOffset
        targetContentOffset.pointee = nearestTargetOffset(for: offset, velocity: velocity)
    }
    
    private func nearestTargetOffset(for offset: CGPoint, velocity: CGPoint) -> CGPoint{
        let pageWidth = UIScreen.main.bounds.width + 32
        //四舍五入
        var page = offset.x / pageWidth
        if velocity.x > 0 {
            page = ceil(page)
        }else if velocity.x < 0 {
            page = floor(page)
        }else {
            page = round(page)
        }
        let x = pageWidth * page
        return CGPoint(x: x, y: 0)
    }
}


extension ImageBrowerController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSources.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageBrowerCell
        cell.imageSource = imageSources[indexPath.row]
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        title = "\(index + 1)/\(imageSources.count)"
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if cell.isKind(of: ImageBrowerCell.self) {
            (cell as! ImageBrowerCell).scrollView.zoomScale = 1
        }
    }
}



class ImageBrowerCell: UICollectionViewCell {
    
    var context = 0
    
    var scrollView = UIScrollView(frame: UIScreen.main.bounds)
    var imgView = UIImageView(frame: UIScreen.main.bounds)
    
    var imageSource: UIImageViewImageSource? {
        didSet {
            imageSource?.imageViewShouldSetImage(imgView)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    private func config() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.contentSize = scrollView.bounds.size
        scrollView.bounces = false
        addSubview(scrollView)
        imgView.contentMode = .scaleAspectFit
        imgView.addObserver(self, forKeyPath: "image", options: .new, context: &context)
        scrollView.addSubview(imgView)
        addTap()
    }
    
    private func addTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(zoomImage))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }
    
    
    @objc private func zoomImage() {
        let zoonScale = scrollView.zoomScale
        if zoonScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        }else {
            scrollView.setZoomScale(3, animated: true)
        }
    }
}

extension ImageBrowerCell {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.context && keyPath == "image" {
            imgViewDidSetImage()
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func imgViewDidSetImage() {
        if let img = imgView.image {
            var size = img.size
            var scale: CGFloat = 1
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height
            if size.width / size.height > screenWidth / screenHeight {
                scale = screenWidth / size.width
            }else {
                scale = screenHeight / size.height
            }
            size = CGSize(width: size.width * scale, height: size.height * scale)
            if size != scrollView.contentSize {
                imgView.bounds = CGRect(origin: .zero, size: size)
                imgView.center = scrollView.center
                scrollView.contentSize = size
            }
        }else {
            imgView.frame = .zero
            imgView.center = scrollView.center
            scrollView.contentSize = .zero
        }
    }
}

extension ImageBrowerCell: UIScrollViewDelegate, UIGestureRecognizerDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let contentW = scrollView.contentSize.width
        let contentH = scrollView.contentSize.height
        let scrollViewWidth = scrollView.bounds.size.width
        let scrollViewHeight = scrollView.bounds.size.height
        let offsetX = scrollViewWidth > contentW ? (scrollViewWidth - contentW) * 0.5 : 0.0
        let offsetY = scrollViewHeight > contentH ? (scrollViewHeight - contentH) * 0.5 : 0.0
        imgView.center = CGPoint(x: contentW * 0.5 + offsetX, y: contentH * 0.5 + offsetY)
    }
}


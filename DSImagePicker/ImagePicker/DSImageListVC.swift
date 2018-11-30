//
//  DSImageListVC.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/27.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit
import Photos

class DSImageListVC: UIViewController {
    
    var album = AlbumItem()
    
    private var maxSelectedCount: Int {
        return DSImagePickerManger.shared.maxImageCount
    }
    
    private var backImages = [UIImage](repeating: UIImage(), count: DSImagePickerManger.shared.maxImageCount)
    private var selectedAssets = [PHAsset]()
    
    private var itemWidth: CGFloat = 0
    private let imageManager = PHCachingImageManager()
    
    var isOriginal = false
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var isOriginalButton: UIButton!
    @IBOutlet weak var showItem: UIBarButtonItem!
    @IBOutlet weak var doneItem: UIBarButtonItem!
    
    private var queue = OperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageManager.stopCachingImagesForAllAssets()
        computeItemWidth()
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
    }
    
    private func computeItemWidth() {
        if UIScreen.main.bounds.size.width >= 375 {
            itemWidth = floor((UIScreen.main.bounds.size.width - 15) / 4)
        }else {
            itemWidth = floor((UIScreen.main.bounds.size.width - 12) / 3)
        }
    }
    @IBAction func done() {
        for asset in selectedAssets {
            let operation = BlockOperation {
                self.requestImageFromAsset(asset)
            }
            queue.addOperation(operation)
        }
        let doneOperation = BlockOperation {
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: nil)
                DSImagePickerManger.shared.resultHandler?(self.backImages.filter{ return $0.size != .zero })
            }
        }
        _ = queue.operations.map {
            doneOperation.addDependency($0)
        }
        queue.addOperation(doneOperation)
    }
    
    private func requestImageFromAsset(_ asset: PHAsset) {
        if isOriginal {
            imageManager.requestOriginalImage(for: asset, options: .sync){ (image) in
                if let image = image {
                    let index = self.selectedAssets.firstIndex(of: asset)!
                    self.backImages[index] = image
                }
            }
        }else {
            imageManager.requestDefaultImage(for: asset, options: .sync){ (image) in
                if let image = image {
                    let index = self.selectedAssets.firstIndex(of: asset)!
                    self.backImages[index] = image
                }
            }
        }
    }
    
    
    @IBAction func browserImages(_ sender: Any) {
        ImageBrowerController.showBrower(with: selectedAssets, sourceVC: self)
    }
    
    @IBAction func userOriginalImage(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isOriginal = sender.isSelected
    }
    
    @IBAction func cancelPick(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension DSImageListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return album.fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DSImageListCell
        let asset = album.fetchResult.object(at: indexPath.row)
        let targetSize = CGSize(width: itemWidth, height: itemWidth)
        imageManager.requestThumbImage(for: asset, targetSize: targetSize) { (image) in
            cell.imgView.image = image
        }
        let selectedIndex = selectedAssets.firstIndex(of: asset)
        cell.selectedIndex = selectedIndex
        cell.isPickable = cell.selectedIndex != nil || selectedAssets.count < maxSelectedCount
        return cell
    }
}

extension DSImageListVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! DSImageListCell
        let asset = album.fetchResult[indexPath.row]
        if cell.selectedIndex != nil {
            selectedAssets.remove(at: cell.selectedIndex!)
        }else if selectedAssets.count < maxSelectedCount {
            selectedAssets.append(asset)
        }else {
            return
        }
        doneItem.title = "完成(\(selectedAssets.count))"
        doneItem.isEnabled = selectedAssets.count > 0
        showItem.isEnabled = selectedAssets.count > 0
        collectionView.reloadData()
    }
}

class DSImageListCell: UICollectionViewCell {
    
    var isPickable = true {
        didSet {
            blurView?.isHidden = isPickable
        }
    }
    var selectedIndex: Int? {
        didSet {
            let isEmpty = selectedIndex == nil
            pickButton.isHidden = isEmpty
            let title = isEmpty ? nil : "\(selectedIndex! + 1)"
            pickButton.setTitle(title, for: .normal)
        }
    }
    
    var blurView: UIView?
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var pickButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        blurView = addBlurEffect()
        blurView?.isHidden = true
    }
    
}

extension UIView {
    @discardableResult
    func addBlurEffect(style: UIBlurEffect.Style = .light) -> UIVisualEffectView {
        let beffect = UIBlurEffect(style: style)
        let view = UIVisualEffectView(effect: beffect)
        view.frame = self.bounds
        view.isUserInteractionEnabled = false
        self.addSubview(view)
        return view
    }
}

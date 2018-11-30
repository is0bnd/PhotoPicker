//
//  GridView.swift
//  GridviewDemo
//
//  Created by shuai on 2018/10/17.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit

@objc protocol GridViewDelegate {
    func gridView(_ gridView: GridView, didSelectItemAt index: Int)
    func gridViewShouldAddImageSources()
}

class GridView: UIView {
    
    @IBInspectable var delegate: GridViewDelegate? = nil
    @IBInspectable var isEditEnable: Bool = true
    @IBInspectable var addImage: UIImage = #imageLiteral(resourceName: "add")
    @IBInspectable var space: CGFloat = 8 {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
            resetHeightConstant()
        }
    }
    
    var imageSources = [UIImageViewImageSource]()
    
    private var dragCell: UICollectionViewCell?
    private var targetView: UIView?
    private var currentIndexPath: IndexPath?
    private let deleteButton: UIButton = {
        let width = UIScreen.main.bounds.size.width
        let y = UIScreen.main.bounds.height - 49
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: y, width: width, height: 49)
        button.backgroundColor = UIColor(red: 1, green: 0.2, blue: 0.2, alpha: 0.8)
        button.setTitle("拖动到此处删除", for: .normal)
        button.setTitle("松开即可删除", for: .selected)
        return button
    }()
    
    private lazy var heightConstraint: NSLayoutConstraint = {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: .height,
                                            relatedBy: .equal,
                                            toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1.0,
                                            constant: 100)
        constraint.priority = UILayoutPriority.fittingSizeLevel
        return constraint
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: "GridViewCell")
        collectionView.backgroundColor = self.backgroundColor
        collectionView.clipsToBounds = false
        return collectionView
    }()
    
    //MARK: - init
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(heightConstraint)
        config()
    }
    
    //MARK: - layout
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = bounds
        collectionView.reloadData()
    }
    
    func reloadData() {
        collectionView.reloadData()
        resetHeightConstant()
    }
    
}

//MARK: - custom function
extension GridView {
    private func config() {
        addSubview(self.collectionView)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(moveCollectionViewItem))
        collectionView.addGestureRecognizer(longPress)
    }
    
    private func resetHeightConstant() {
        let width = floor((frame.size.width - space * 2) / 3)
        var rowCount = ceil(CGFloat(imageSources.count) / 3)
        rowCount = isEditEnable ? rowCount + 1 : rowCount
        rowCount = min(3, rowCount)
        let height = rowCount * (width + space) - space
        heightConstraint.constant = max(0, height)
    }
    
    @objc private func moveCollectionViewItem(by gestureRecognizer: UILongPressGestureRecognizer) {
        if isEditEnable == false {
            return
        }
        let point = gestureRecognizer.location(in: collectionView)
        switch gestureRecognizer.state {
        case .began:
            longPressGestureRecognizerBeganAtPoint(point)
        case .changed:
            longPressGestureRecognizerMoveToPoint(point)
        case .ended:
            longPressGestureRecognizerEndedAtPoint(point)
        default:
            longPressGestureRecognizerOtherStateAtPoint(point)
        }
    }
    
    private func longPressGestureRecognizerBeganAtPoint(_ point: CGPoint) {
        if let indexPath = collectionView.indexPathForItem(at: point) {
            print("began at indexpath \(indexPath)")
            if indexPath.row < imageSources.count {
                currentIndexPath = indexPath
                dragCell = collectionView.cellForItem(at: indexPath)
                targetView = dragCell?.snapshotView(afterScreenUpdates: true)
                dragCell?.isHidden = true
                targetView?.center = dragCell!.center
                collectionView.addSubview(targetView!)
                shack()
                showDeleteButton()
            }else {
                return
            }
        }
    }
    
    private func longPressGestureRecognizerMoveToPoint(_ point: CGPoint) {
        targetView?.center = point
        let windowsPoint = collectionView.convert(point, to: nil)
        changeDeleteButtonStateWithPoint(windowsPoint)
        print(point)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            print("move to indexpath \(indexPath)")
            let index = imageSources.count
            if indexPath.row < index {
                if indexPath != currentIndexPath {
                    let image = imageSources[currentIndexPath!.row]
                    imageSources.remove(at: currentIndexPath!.row)
                    imageSources.insert(image, at: indexPath.row)
                    collectionView.moveItem(at: currentIndexPath!, to: indexPath)
                    shack()
                    currentIndexPath = indexPath
                }
            } else {
                return
            }
        }
    }
    
    private func longPressGestureRecognizerEndedAtPoint(_ point: CGPoint) {
        targetView?.removeFromSuperview()
        dragCell?.isHidden = false
        if deleteButton.isSelected {
            if let index = currentIndexPath?.row {
                imageSources.remove(at: index)
                CATransaction.setDisableActions(true)
                collectionView.reloadSections([0])
                CATransaction.commit()
            }
        }
        targetView = nil
        currentIndexPath = nil
        removeDeleteButton()
        resetHeightConstant()
    }
    
    private func longPressGestureRecognizerOtherStateAtPoint(_ point: CGPoint) {
        removeDeleteButton()
        dragCell = nil
    }
    
    private func shack() {
        let feedBack = UIImpactFeedbackGenerator(style:.medium)
        feedBack.prepare()
        feedBack.impactOccurred()
    }
    
    private func showDeleteButton() {
        if let window = UIApplication.shared.windows.last {
            window.addSubview(deleteButton)
        }
    }
    
    private func removeDeleteButton() {
        deleteButton.isSelected = false
        deleteButton.removeFromSuperview()
    }
    
    private func changeDeleteButtonStateWithPoint(_ point: CGPoint) {
        if point.y >= UIScreen.main.bounds.size.height - 49 {
            if deleteButton.isSelected == false {
                shack()
                deleteButton.isSelected = true
            }
        }else {
            if deleteButton.isSelected == true {
                shack()
                deleteButton.isSelected = false
            }
        }
    }
}

extension GridView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isEditEnable && imageSources.count < 9 {
            return imageSources.count + 1
        }else {
            return imageSources.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell", for: indexPath) as! GridViewCell
        if indexPath.row < imageSources.count {
            cell.imageSource = imageSources[indexPath.row]
        }else {
            cell.imageSource = addImage
        }
        return cell
    }
    
}

extension GridView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // delegate?.gridView(self, didSelectImageAt: indexPath.row)
        if indexPath.row < imageSources.count {
            delegate?.gridView(self, didSelectItemAt: indexPath.row)
        }else {
            delegate?.gridViewShouldAddImageSources()
        }
    }
    
}

extension GridView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = floor((collectionView.frame.size.width - space * 2) / 3)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return space
    }
}


class GridViewCell: UICollectionViewCell {
    
    var imageSource: UIImageViewImageSource? {
        didSet {
            imageSource?.imageViewShouldSetImage(imageView)
        }
    }
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        config()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        config()
    }
    
    private final func config() {
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.bounds
    }
}






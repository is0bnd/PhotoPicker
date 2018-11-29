//
//  ViewController.swift
//  TestDemo
//
//  Created by 韩兆华 on 2018/11/26.
//  Copyright © 2018 韩兆华. All rights reserved.
//

import UIKit
import CoreAudioKit

class ViewController: UIViewController {
    
    var images = [#imageLiteral(resourceName: "add")]
    
    private var dragCell: UICollectionViewCell?
    private var targetView: UIView?
    private var currentIndexPath: IndexPath?
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewHeightLayout: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var textViewHeightLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(moveCollectionViewItem))
        collectionView.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionViewHeightLayout.constant = collectionView.contentSize.height
    }
    
    @objc private func moveCollectionViewItem(by gestureRecognizer: UILongPressGestureRecognizer) {
        let point = gestureRecognizer.location(in: collectionView)
        switch gestureRecognizer.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: point) {
                let index = images.firstIndex(of: #imageLiteral(resourceName: "add"))!
                if indexPath.row < index {
                    currentIndexPath = indexPath
                    dragCell = collectionView.cellForItem(at: indexPath)
                    targetView = dragCell?.snapshotView(afterScreenUpdates: true)
                    dragCell?.isHidden = true
                    targetView?.center = dragCell!.center
                    collectionView.addSubview(targetView!)
                    shack()
                    deleteButton.isHidden = false
                }else {
                    return
                }
            }
        case .changed:
            targetView?.center = point
            if point.y >= deleteButton.frame.origin.y - 100 {
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
            if let indexPath = collectionView.indexPathForItem(at: point) {
                let index = images.firstIndex(of: #imageLiteral(resourceName: "add"))!
                if indexPath.row < index {
                    if indexPath != currentIndexPath {
                        let image = images[currentIndexPath!.row]
                        images.remove(at: currentIndexPath!.row)
                        images.insert(image, at: indexPath.row)
                        collectionView.moveItem(at: currentIndexPath!, to: indexPath)
                        shack()
                        currentIndexPath = indexPath
                    }
                } else {
                    return
                }
            }
        case .ended:
            targetView?.removeFromSuperview()
            dragCell?.isHidden = false
            if deleteButton.isSelected {
                if let index = currentIndexPath?.row {
                    images.remove(at: index)
                    CATransaction.setDisableActions(true)
                    collectionView.reloadSections([0])
                    CATransaction.commit()
                }
                
            }
            targetView = nil
            currentIndexPath = nil
            deleteButton.isHidden = true
            var lines = ceil(CGFloat(images.count) / 3)
            lines = lines > 3 ? 3 : lines
            collectionViewHeightLayout.constant =  (collectionView.bounds.size.width - 80) / 3 * lines
        default:
            collectionView.cancelInteractiveMovement()
            deleteButton.isHidden = true
            dragCell = nil
        }
    }
    
    
    private func shack() {
        let feedBack = UIImpactFeedbackGenerator(style:.medium)
        feedBack.prepare()
        feedBack.impactOccurred()
    }
    
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let fitSize = CGSize(width: textView.bounds.size.width,
                             height: CGFloat.greatestFiniteMagnitude)
        textView.sizeToFit()
        let height = textView.sizeThatFits(fitSize).height + 16
        if height >= 300 {
            textViewHeightLayout.constant = 300
        } else {
            textViewHeightLayout.constant = height
        }
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = images.firstIndex(of: #imageLiteral(resourceName: "add"))!
        if indexPath.row == index {
            DSImagePickerManger.shared.pickImage(maxImageCount: 9 - index, sourceVC: self) { (images) in
                print(images)
                self.images.insert(contentsOf: images, at: index)
                self.collectionView.reloadData()
            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let index = images.firstIndex(of: #imageLiteral(resourceName: "add"))!
        if indexPath.row <= index && indexPath.row < 9 {
            let width = floor((collectionView.frame.size.width - 80) / 3)
            return CGSize(width: width, height: width)
        }else {
            return CGSize.zero
        }
    }
    
}


class CollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
}

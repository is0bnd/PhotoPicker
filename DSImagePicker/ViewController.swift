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
    
    @IBOutlet weak var gridView: GridView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightLayout: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gridView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension ViewController: GridViewDelegate {
    func gridView(_ gridView: GridView, didSelectItemAt index: Int) {
        print(index)
    }
    
    func gridViewShouldAddImageSources() {
        let count = 9 - gridView.imageSources.count
        DSImagePickerManger.shared.pickImage(maxImageCount: count, isImageOriginal: true, sourceVC: self) { (images) in
            self.gridView.imageSources.append(contentsOf: images)
            self.gridView.reloadData()
        }
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

//
//  DSImageBrowserManager.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/29.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit
import Photos

protocol UIImageViewImageSource {
    func imageViewShouldSetImage(_ imageView: UIImageView)
}

extension PHAsset: UIImageViewImageSource {
    func imageViewShouldSetImage(_ imageView: UIImageView) {
        PHCachingImageManager().requestOriginalImage(for: self) { (image) in
            imageView.image = image
        }
    }
}

extension UIImage: UIImageViewImageSource {
    func imageViewShouldSetImage(_ imageView: UIImageView) {
        imageView.image = self
    }
}


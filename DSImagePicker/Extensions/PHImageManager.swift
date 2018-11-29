//
//  PHImageManager.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/29.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import PhotosUI

extension PHImageManager {
    @discardableResult
    func requestThumbImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        let scale = UIScreen.main.scale
        let newSize = CGSize(width: targetSize.width * scale,
                             height: targetSize.height * scale)
        return requestImage(for: asset, targetSize: newSize, contentMode: .aspectFill, options: .thumb) { (image, _) in
            resultHandler(image)
        }
    }
    @discardableResult
    func requestDefaultImage(for asset: PHAsset, resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        return requestImage(for: asset, targetSize: CGSize(width: 1024, height: 1024), contentMode: .default, options: .default) { (image, _) in
            resultHandler(image)
        }
    }
    
    @discardableResult
    func requestOriginalImage(for asset: PHAsset, resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        return requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: .original){ (image, _) in
            resultHandler(image)
        }
    }
}


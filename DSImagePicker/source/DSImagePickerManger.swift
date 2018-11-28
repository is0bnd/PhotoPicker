//
//  DSImagePickerManger.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/28.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit

class DSImagePickerManger: NSObject {
    
    private(set) var resultHandler: (([UIImage]) -> Void)?
    private(set) var maxImageCount = 1
    
}

extension DSImagePickerManger {
    
    static let shared = DSImagePickerManger()
    
    func pickImage(maxImageCount: Int,
                   isImageOriginal: Bool = false,
                   sourceVC: UIViewController,
                   resultHandler: @escaping ([UIImage]) -> Void) {
        self.resultHandler = resultHandler
        self.maxImageCount = maxImageCount
        
        let storyboard = UIStoryboard(name: "DSImagePicker", bundle: nil)
        if let toVC = storyboard.instantiateInitialViewController() {
            sourceVC.show(toVC, sender: nil)
        }else {
            fatalError("can not find instantiateInitialViewController in storyboard named DSImagePicker")
        }
    }
}

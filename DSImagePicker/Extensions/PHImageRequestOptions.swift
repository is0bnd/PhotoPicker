//
//  PHImageRequestOptions.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/29.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import PhotosUI

extension PHImageRequestOptions {
    static let thumb: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.deliveryMode = .fastFormat
        options.resizeMode = .exact
        return options
    }()
    
    static let `default`: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.resizeMode = .none
        return options
    }()
    
    static let original: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.resizeMode = .none
        return options
    }()
    
    
}


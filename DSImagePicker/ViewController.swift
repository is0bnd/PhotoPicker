//
//  ViewController.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/27.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func pickImage(_ sender: Any) {
        DSImagePickerManger.shared.pickImage(maxImageCount: 4, sourceVC: self) { (images) in
            print(images)
        }
    }
    
}


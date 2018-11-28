//
//  DSAlbumListVC.swift
//  DSImagePicker
//
//  Created by shuai on 2018/11/27.
//  Copyright © 2018 is0bnd. All rights reserved.
//

import UIKit
import Photos

//相簿列表项
class AlbumItem {
    //相簿名称
    var title:String?
    //相簿内的资源
    var fetchResult:PHFetchResult<PHAsset>
    
    init() {
        fetchResult = PHFetchResult<PHAsset>()
    }
    
    init(title:String?,fetchResult:PHFetchResult<PHAsset>){
        self.title = title
        self.fetchResult = fetchResult
    }
}

class DSAlbumListVC: UITableViewController {
    
    var items:[AlbumItem] = []
    let imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 列出所有系统的智能相册
        let smartOptions = PHFetchOptions()
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: smartOptions)
        self.convertCollection(smartAlbums)
        
    
        //列出所有用户创建的相册
        let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        self.convertCollection(userCollections)
        
        //相册按包含的照片数量排序（降序）
        self.items.sort {
            return $0.fetchResult.count > $1.fetchResult.count
        }
    }
    
    //转化处理获取到的相簿
    private func convertCollection<T: PHCollection>(_ collection:PHFetchResult<T>){
        
        for i in 0..<collection.count{
            //获取出但前相簿内的图片
            let resultsOptions = PHFetchOptions()
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            resultsOptions.predicate = NSPredicate(format: "mediaType = %d",
                                                   PHAssetMediaType.image.rawValue)
            guard let c = collection[i] as? PHAssetCollection else { return }
            let assetsFetchResult = PHAsset.fetchAssets(in: c ,options: resultsOptions)
            //没有图片的空相簿不显示
            if assetsFetchResult.count > 0{
                items.append(AlbumItem(title: c.localizedTitle, fetchResult: assetsFetchResult))
            }
        }
        
    }
    
    //表格分区数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //表格单元格数量
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    //设置单元格内容
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identify:String = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identify, for: indexPath)
        let item = self.items[indexPath.row]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "(\(item.fetchResult.count))"
        imageManager.requestThumbImage(for: item.fetchResult.firstObject!,
                                       targetSize: CGSize(width: 64, height: 64)) { image in
            cell.imageView?.image = image
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        performSegue(withIdentifier: "detail", sender: item)
    }
    
    //页面跳转
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail"{
            let item = sender as! AlbumItem
            let toVC = segue.destination as! DSImageListVC
            toVC.title = item.title
            toVC.album = item
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

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
        options.isSynchronous = true
        options.resizeMode = .none
        return options
    }()
    
    static let original: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.resizeMode = .none
        return options
    }()
    
    
}

extension PHImageManager {
    @discardableResult
    func requestThumbImage(for asset: PHAsset, targetSize: CGSize, resultHandler: @escaping (UIImage?) -> Void) -> PHImageRequestID {
        let scale = UIScreen.main.scale
        print(scale)
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

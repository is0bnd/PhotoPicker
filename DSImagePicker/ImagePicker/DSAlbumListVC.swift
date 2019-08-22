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


// 相册列表页面
class DSAlbumListVC: UITableViewController {
    
    // 相册列表
    var items:[AlbumItem] = []
    // 请求图片工具
    let imageManager = PHCachingImageManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // requestAllAlbums()
        checkPermissions()
    }
    
    
    @IBAction func cancelPick(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
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

extension DSAlbumListVC {
    private func requestAllAlbums() {
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
            // 按照创建时间排序
            resultsOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                               ascending: false)]
            // 只过滤图片
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
}

extension DSAlbumListVC {
    
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
    
}

extension DSAlbumListVC {
    private func checkPermissions() {
        let status = PHPhotoLibrary.authorizationStatus()
        reloadStatus(status)
    }
    
    private func reloadStatus(_ status: PHAuthorizationStatus) {
        switch status {
        case .notDetermined: // 未选择
            shouldRequestAuthorization()
        case .restricted: // 用户权限受限
            alertRestricted()
        case .denied: // 已拒绝
            alertDenied()
        case .authorized: // 已授权
            didAuthorized()
        @unknown default:
            unknowStatus()
        }
    }
    
    private func shouldRequestAuthorization() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            self?.reloadStatus(status)
        }
    }
    
    private func alertRestricted() {
        let message = #"您的权限受限, 联系管理员(例如家长)开启权限"#
        let alert = UIAlertController(title: "温馨提示", message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(done)
        present(alert, animated: true, completion: nil)
    }
    
    private func alertDenied() {
        let message = #"请在iPhone的"设置-隐私-照片"选项中, 允许APP访问您的手机相册"#
        let alert = UIAlertController(title: "温馨提示", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let set = UIAlertAction(title: "去设置", style: .default) { _ in
            let url = URL(string: UIApplication.openSettingsURLString)!
            UIApplication.shared.open(url)
        }
        alert.addAction(cancel)
        alert.addAction(set)
        present(alert, animated: true, completion: nil)
    }
    
    private func didAuthorized() {
        requestAllAlbums()
    }
    
    private func unknowStatus() {
        let message = #"未知异常错误,请稍后再试!"#
        let alert = UIAlertController(title: "温馨提示", message: message, preferredStyle: .alert)
        let done = UIAlertAction(title: "确定", style: .default) { [weak self] _ in
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        alert.addAction(done)
        present(alert, animated: true, completion: nil)
    }

}


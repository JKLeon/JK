//
//  PhotoCollectionViewController.swift
//  JK
//
//  Created by JK on 2018/9/17.
//  Copyright © 2018 JK. All rights reserved.
//

import Foundation
import UIKit
import YNDropDownMenu
import collection_view_layouts

class PhotoCollectionViewController: UICollectionViewController, ImageServiceDelegate, ContentDynamicLayoutDelegate {
    
    var imageList: NSArray! = []
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    var cellPaddingHorizonal: CGFloat! = 10
    var cellPaddingVertical: CGFloat! = 10
    var imageCount: Int!
    var plistPath: String!
    var dropDownView: UIView!
    var contentFlowLayout: ContentDynamicLayout = TagsStyleFlowLayout()
    let FF00FF = UIColor.init(red: 255/255, green: 0/255, blue: 255/255, alpha: 1.0)
    let BA63C6 = UIColor.init(red: 186/255, green: 99/255, blue: 198/255, alpha: 1.0)

    func cellSize(indexPath: IndexPath) -> CGSize {
        let screenFrame = UIScreen.main.bounds;
        return CGSize(width: (screenFrame.width-4*cellPaddingHorizonal)/2, height: (screenFrame.width-4*cellPaddingHorizonal)/2)
    }
    
    func initImagePath() {
        fatalError("Must override initImagePath")
    }

    override func viewDidLoad() {
        initImagePath()
        resetImageList(path: plistPath)
        
        let screenFrame = UIScreen.main.bounds;
        screenWidth = screenFrame.size.width;
        screenHeight = screenFrame.size.height;
        
        ImageService.imageServiceInstance.delegate = self
        
        let FilterViews = Bundle.main.loadNibNamed("FilterViews", owner: nil, options: nil) as? [UIView]
        
        if let _filterViews = FilterViews {
            // Inherit YNDropDownView if you want to hideMenu in your dropDownViews
            var filterView = YNDropDownMenu(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight*0.08), dropDownViews: _filterViews, dropDownViewTitles: [""])
            filterView.setImageWhens(normal: [UIImage(named: "favorite")], selectedTintColor: UIColor.purple, disabledTintColor: UIColor.gray)
            filterView.setLabelColorWhen(normal: FF00FF, selected: UIColor.purple, disabled: UIColor.gray)
            filterView.setLabelFontWhen(normal: .systemFont(ofSize: 12), selected: .systemFont(ofSize: 12), disabled: .systemFont(ofSize: 12))
            filterView.backgroundColor = UIColor.black
            filterView.setBackgroundColor(color: UIColor.black)
            dropDownView = filterView
            self.view.addSubview(dropDownView)
        }
        
        setUpFlowLayout()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageCount = imageList.count;
        return imageCount;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let CellIdentifier = "ImageViewCell";
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath);
        let row = (indexPath as NSIndexPath).row;
        let cellDict = imageList[row] as! NSDictionary;
        let imagePath = String(format: "%@.jpeg", cellDict["name"] as! String);
        let uiImageCellView = cell.backgroundView as! UIImageView;
        uiImageCellView.image = originalImageScaleToSize(originImage: UIImage.init(named: imagePath)!, withScaleSize: CGSize(width: (screenWidth-4*cellPaddingHorizonal)/2, height: (screenWidth-4*cellPaddingHorizonal)/2));
        return cell;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowPhotoDetail")
        {
            if let selectedIndexPath = collectionView?.indexPathsForSelectedItems?.first{
                let photoDetailController = segue.destination as! PhotoDetailViewController;
                let row = selectedIndexPath.row;
                let cellDict = imageList[row] as! NSDictionary;
                let imagePath = String(format: "%@.jpeg", cellDict["name"] as! String);
                collectionView?.addSubview(photoDetailController.view); //add subview before set value for outlet imageView
                photoDetailController.imageView.image = originalImageScaleToSize(originImage: UIImage.init(named: imagePath)!, withScaleSize: CGSize(width: screenWidth, height: screenWidth));
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        screenWidth = size.width
        screenHeight = size.height
        dropDownView?.frame.size.width = screenWidth
        dropDownView?.frame.size.height = screenHeight*0.08
        collectionView?.reloadData()
    }
    
    func applyFilter(filters: Array<String>!) {
       resetImageList(path: plistPath)
       imageList = imageList.filter {
            let cellDict = $0 as! NSDictionary
            let imageTags = cellDict["tags"] as! NSArray
            
            let canDisplayedImage = imageTags.filter {
                let tag = $0 as! String
                return filters.contains(tag)
            }
            
            return !canDisplayedImage.isEmpty
        } as NSArray
        collectionView?.reloadData()
    }
    
    func resetImageList(path: String) {
        imageList = NSArray.init(contentsOfFile: path);
    }
    
    func setUpFlowLayout() {
        contentFlowLayout.delegate = self
        contentFlowLayout.contentPadding = ItemsPadding(horizontal: 10, vertical: 10)
        contentFlowLayout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)
        contentFlowLayout.contentAlign = .left
        
        collectionView?.collectionViewLayout = contentFlowLayout
        collectionView?.reloadData()
    }

    func originalImageScaleToSize(originImage:UIImage, withScaleSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContext(withScaleSize);// 创建一个bitmap的context，并把它设置成为当前正在使用的context
        originImage.draw(in: CGRect(x: 0, y: 0, width: withScaleSize.width, height: withScaleSize.height));// 绘制改变大小的图片，self指的是原图片
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext();// 从当前context中创建一个改变大小后的图片
        UIGraphicsEndImageContext();// 使当前的context出堆栈
        return scaledImage as! UIImage;// 返回新的改变大小后的图片
    }
}

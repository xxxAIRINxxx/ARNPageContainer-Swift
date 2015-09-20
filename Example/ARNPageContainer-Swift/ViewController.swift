//
//  ViewController.swift
//  ARNPageContainer-Swift
//
//  Created by xxxAIRINxxx on 2015/01/20.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var pageContainer : ARNPageContainer = ARNPageContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageContainer.setPasentVC(self)
        
        for index in 1...5 {
            let controller = UIViewController()
            controller.view.clipsToBounds = true
            let imageView = UIImageView(image: UIImage(named: "image.JPG"))
            imageView.contentMode = .ScaleAspectFill
            controller.view.addSubview(imageView)
            controller.view.arn_allPin(imageView)
            controller.title = "controller \(index)"
            self.pageContainer.addViewController(controller)
        }
        
        let tabView = ARNPageContainerTabView(frame: CGRectZero)
        tabView.font = UIFont.boldSystemFontOfSize(20)
        tabView.backgroundColor = UIColor.darkGrayColor()
        tabView.titleColor = UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        tabView.itemTitles = self.pageContainer.headerTitles()
        pageContainer.setTopBarView(tabView)
        
        weak var weakTabView = tabView
        self.pageContainer.changeOffsetHandler = {(collectionView: UICollectionView, selectedIndex: Int) in
            if let _tabView = weakTabView {
                _tabView.changeParentScrollView(collectionView, selectedIndex: selectedIndex, totalVCCount: collectionView.numberOfItemsInSection(0))
            }
        }
        
        weak var weakSelf = self
        tabView.selectTitleHandler = {(selectedIndex: Int) in
            print("selectTitleBlock selectedIndex : \(selectedIndex)")
            if let _self = weakSelf {
                _self.pageContainer.setSelectedIndex(selectedIndex, animated: true)
            }
        }
        
        self.pageContainer.changeIndexHandler = {(selectIndexController: UIViewController, selectedIndex: Int) in
            print("changeIndexBlock selectedIndex : \(selectedIndex)")
            if let _tabView = weakTabView {
                _tabView.selectedIndex = selectedIndex
            }
        }
        
        self.pageContainer.setSelectedIndex(2, animated: true)
        self.pageContainer.topBarHeight = 60.0
    }
}


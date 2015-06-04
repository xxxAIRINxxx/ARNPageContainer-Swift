//
//  ARNPageContainer.swift
//  ARNPageContainer-Swift
//
//  Created by xxxAIRINxxx on 2015/01/20.
//  Copyright (c) 2015 Airin. All rights reserved.
//

import UIKit

public class ARNPageContainer: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {
    
    public let topBarLayerViewDefaultHeight : CGFloat = 44.0
    
    public var changeOffsetHandler : ((collectionView: UICollectionView, selectedIndex: Int) ->())?
    public var changeIndexHandler : ((selectIndexController: UIViewController, selectedIndex: Int) ->())?
    public var updateHeaderTitleHandler : ((headerTitles: [String]?) ->())?
    
    var currentIndex : Int = 0
    public var selectedIndex : Int {
        get {
            return currentIndex
        }
        set {
            self.setSelectedIndex(newValue, animated: false)
        }
    }
    
    public var topBarHeight : CGFloat {
        get {
            return self.barLayerViewHeightConstraint?.constant ?? 0
        }
        set {
            if self.barLayerViewHeightConstraint != nil {
                self.barLayerViewHeightConstraint!.constant = newValue
            }
        }
    }
    
    public var topMargin : CGFloat {
        get {
            return self.topConstraint?.constant ?? 0.0
        }
        set {
            if self.topConstraint != nil {
                self.topConstraint!.constant = newValue
            }
        }
    }
    
    public var bottomMargin : CGFloat {
        get {
            return self.bottomConstraint?.constant ?? 0.0
        }
        set {
            if self.bottomConstraint != nil {
                self.bottomConstraint!.constant = -newValue
            }
        }
    }
    
    public lazy var collectionView : UICollectionView = {
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .Horizontal
        
        var collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pagingEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        self.view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.clearColor()
        
        return collectionView
    }()
    
    public lazy var topBarLayerView : UIView = {
        var view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.blackColor()
        self.view.addSubview(view)
        
        return view
    }()
    
    var viewControllers : [[String : UIViewController]] = []
    
    var topConstraint : NSLayoutConstraint?
    var bottomConstraint : NSLayoutConstraint?
    var barLayerViewHeightConstraint : NSLayoutConstraint?
    
    weak var observingScrollView : UIScrollView?
    var shouldObserveContentOffset : Bool = false
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        self.stopObservingContentOffset()
        self.shouldObserveContentOffset = false
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.setupConstraint()
        
        self.shouldObserveContentOffset = true
        self.startObservingContentOffsetForScrollView(self.collectionView)
    }
    
    func setupConstraint() {
        self.view.arn_addPin(self.topBarLayerView, attribute: .Top, toView: self.view, constant: 0.0)
        self.barLayerViewHeightConstraint = view.arn_addHeightConstraint(self.topBarLayerView, constant: self.topBarLayerViewDefaultHeight)
        self.view.arn_addPin(self.topBarLayerView, attribute: .Left, toView: self.view, constant: 0.0)
        self.view.arn_addPin(self.topBarLayerView, attribute: .Right, toView: self.view, constant: 0.0)
        
        self.view.arn_addPin(self.collectionView, isWithViewTop: true, toView: self.topBarLayerView, isToViewTop: false, constant: 0.0)
        self.view.arn_addPin(self.collectionView, attribute: .Bottom, toView: self.view, constant: 0.0)
        self.view.arn_addPin(self.collectionView, attribute: .Left, toView: self.view, constant: 0.0)
        self.view.arn_addPin(self.collectionView, attribute: .Right, toView: self.view, constant: 0.0)
    }
    
    public func setPasentVC(parentVC: UIViewController) {
        self.willMoveToParentViewController(self)
        parentVC.view.addSubview(self.view)
        
        self.topConstraint = parentVC.view.arn_addPin(self.view, attribute: .Top, toView: parentVC.view, constant: 0.0)
        self.bottomConstraint = parentVC.view.arn_addPin(self.view, attribute: .Bottom, toView: parentVC.view, constant: 0.0)
        parentVC.view.arn_addPin(self.view, attribute: .Left, toView: parentVC.view, constant: 0.0)
        parentVC.view.arn_addPin(self.view, attribute: .Right, toView: parentVC.view, constant: 0.0)
        
        self.didMoveToParentViewController(parentVC)
    }
    
    public func setTopBarView(view: UIView) {
        for subview in self.topBarLayerView.subviews {
            subview.removeFromSuperview()
        }

        self.topBarLayerView.addSubview(view)
        self.topBarLayerView.arn_allPin(view)
    }
    
    public func addViewController(controller: UIViewController) {
        let uuid = NSUUID().UUIDString
        
        self.viewControllers.append([uuid : controller])
        
        self.collectionView.registerClass(ARNPageContainerViewCell.classForCoder(), forCellWithReuseIdentifier: uuid)
        self.collectionView.reloadData()
        
        let indexPath = NSIndexPath(forItem: self.viewControllers.count - 1, inSection: 0)
        self.collectionView.cellForItemAtIndexPath(indexPath)
    }
    
    public func addViewControllers(viewControllers: [UIViewController]) {
        for controller in viewControllers {
            self.addViewController(controller)
        }
    }
    
    public func setSelectedIndex(selectedIndex: Int, animated: Bool) {
        if selectedIndex >= self.viewControllers.count {
            return
        }
        
        weak var weakSelf = self
        self.collectionView.performBatchUpdates({ () -> Void in
            if let _self = weakSelf {
                _self.collectionView.reloadData()
            }
            }, completion: { (finished) -> Void in
            if let _self = weakSelf {
                _self.collectionView.scrollToItemAtIndexPath(
                    NSIndexPath(forItem: selectedIndex, inSection: 0),
                    atScrollPosition: .CenteredHorizontally,
                    animated: animated
                )
                
                
                if animated == false {
                    _self.collectionView.userInteractionEnabled = true
                    _self.changeOffsetHandler?(collectionView: _self.collectionView, selectedIndex: selectedIndex)
                }
                
                if let _changeIndexHandler = _self.changeIndexHandler {
                    let dict = _self.viewControllers[selectedIndex]
                    let controller = dict.values.first
                    _changeIndexHandler(selectIndexController: controller!, selectedIndex: selectedIndex)
                }
                
                _self.collectionView.collectionViewLayout.invalidateLayout()
            }
        })
        self.currentIndex = selectedIndex
    }
    
    public func headerTitles() -> [String] {
        var headerTitles = [String]()
        
        for dict in viewControllers {
            let controller = dict.values.first
            if let _title = controller?.title {
                headerTitles.append(_title)
            }
        }
        
        return headerTitles
    }
    
    public func updateHeaderTitle() {
        self.updateHeaderTitleHandler?(headerTitles: self.headerTitles())
    }
    
    // MARK: KVO
    
    func startObservingContentOffsetForScrollView(scrollView: UIScrollView) {
        self.stopObservingContentOffset()
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        self.observingScrollView = scrollView
    }
    
    func stopObservingContentOffset() {
        if let _observingScrollView = self.observingScrollView {
            _observingScrollView.removeObserver(self, forKeyPath: "contentOffset")
            self.observingScrollView = nil
        }
    }
    
    public override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let oldX = CGFloat(self.selectedIndex) * self.collectionView.frame.width
        
        if oldX != self.collectionView.contentOffset.x && self.shouldObserveContentOffset {
            if let _changeOffsetHandler = self.changeOffsetHandler {
                _changeOffsetHandler(collectionView:collectionView, selectedIndex: self.selectedIndex)
            }
        }
    }
    
    // MARK: UICollectionView DataSource
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewControllers.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell  {
        let dict = self.viewControllers[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(dict.keys.first!, forIndexPath: indexPath) as! ARNPageContainerViewCell
        
        if cell.contentView.subviews.count == 0 {
            let controller = dict.values.first!
            cell.add(controller.view)
        }
        
        return cell as UICollectionViewCell
    }
    
    // MARK: UICollectionViewFlowLayout Delegate
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return self.collectionView.frame.size
    }
    
    // MARK: UIScrollView Delegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = false
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.selectedIndex = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        scrollView.userInteractionEnabled = true
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            scrollView.userInteractionEnabled = true
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollView.userInteractionEnabled = true
    }
}

public class ARNPageContainerViewCell : UICollectionViewCell {
    
    var dummyContentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.dummyContentView)
        self.arn_allPin(self.dummyContentView)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func add(contentView: UIView) {
        
        self.dummyContentView.addSubview(contentView)
        self.dummyContentView.arn_allPin(contentView)
    }
}

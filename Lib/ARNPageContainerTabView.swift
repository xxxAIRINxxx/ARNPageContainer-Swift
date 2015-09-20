//
//  ARNPageContainerTabView.swift
//  ARNPageContainer-Swift
//
//  Created by xxxAIRINxxx on 2015/01/20.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

public class ARNPageContainerTabView: UIView {
    
    public var selectTitleHandler : ((selectedIndex: Int) ->())?
    
    public var titleColor : UIColor = UIColor.lightGrayColor() {
        didSet {
            self.resetButtonTitleColor()
        }
    }
    
    public var highlightedTitleColor : UIColor = UIColor.whiteColor() {
        didSet {
            self.resetButtonTitleColor()
        }
    }
    
    public var font : UIFont = UIFont.boldSystemFontOfSize(17.0) {
        didSet {
            for index in 0..<self.buttons.count {
                let button = self.buttons[index]
                if let _titleLabel = button.titleLabel {
                    _titleLabel.font = self.font
                }
            }
        }
    }
    
    public var backgroundImage : UIImage? {
        get {
            return self.backGroundImageiew.image
        }
        set {
            self.backGroundImageiew.image = newValue
        }
    }
    
    public var itemTitles : [String] {
        get {
            var titles : [String] = []
            for subview in self.scrollView.subviews {
                let button = subview as! UIButton
                if let _title = button.titleForState(.Normal) {
                    titles.append(_title)
                }
            }
            return titles
        }
        set {
            self.cleanup()
            
            for index in 0..<newValue.count {
                let title = newValue[index]
                let button = self.itemButton()
                button.setTitle(title, forState: .Normal)
                button.tag = index
                self.buttons.append(button)
            }
            self.layoutItemViews()
        }
    }
    
    public var selectedIndex : Int = 0 {
        didSet {
            self.layoutItemViews()
        }
    }
    
    public var itemMargin : CGFloat = 30.0 {
        didSet {
           self.layoutItemViews()
        }
    }
    
    public var minItemWidth : CGFloat = 100.0 {
        didSet {
            self.layoutItemViews()
        }
    }

    public lazy var scrollView : UIScrollView = {
        var scrollView = UIScrollView(frame: self.bounds)
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.scrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var backGroundImageiew : UIImageView = {
        var backGroundImageiew = UIImageView(frame: self.bounds)
        backGroundImageiew.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return backGroundImageiew
    }()
    
    var buttons : [UIButton] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backGroundImageiew)
        self.addSubview(self.scrollView)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cleanup() {
        for button in self.scrollView.subviews {
            button.removeFromSuperview()
        }
        self.buttons.removeAll(keepCapacity: false)
    }
    
    func itemButton() -> UIButton {
        let button = UIButton(frame: CGRectMake(0.0, 0.0, self.minItemWidth, self.frame.height))
        button.titleLabel?.font = self.font
        button.setTitleColor(self.titleColor, forState: .Normal)
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(button)
        
        return button
    }
    
    func resetButtonTitleColor() {
        for index in 0..<self.buttons.count {
            let button = self.buttons[index]
            button.setTitleColor(self.titleColor, forState: .Normal)
            button.setTitleColor(self.highlightedTitleColor, forState: .Highlighted)
            button.setTitleColor(self.highlightedTitleColor, forState: .Selected)
        }
    }
    
    func buttonTapped(sender : UIButton) {
        self.resetButtonTitleColor()
        self.selectTitleHandler?(selectedIndex: sender.tag)
    }
    
    func centerForSelectedItemAtIndex(index : Int) -> (CGPoint) {
        if self.buttons.count <= index {
            return CGPointZero
        }
        let view = self.buttons[index]
        let offset = self.contentOffsetForSelectedItemAtIndex(index)
        var center = view.center
        center.x -= offset.x - CGRectGetMinX(self.scrollView.frame)
        return center
    }
    
    func contentOffsetForSelectedItemAtIndex(index : Int) -> (CGPoint) {
        if self.buttons.count <= index || self.buttons.count == 1 {
            return CGPointZero
        }
        let totalOffset : CGFloat = self.scrollView.contentSize.width - self.scrollView.frame.width
        let xPosition : CGFloat = CGFloat(index) * totalOffset / CGFloat((self.buttons.count - 1))
        return CGPointMake(xPosition, 0.0)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.layoutItemViews()
    }
    
    func layoutItemViews() {
        var x = self.itemMargin
        
        for index in 0..<self.buttons.count {
            let button = self.buttons[index]
            let fontAttr = [NSFontAttributeName : button.titleLabel!.font]
            var width = NSString(string: button.titleLabel!.text!).sizeWithAttributes(fontAttr).width
            if width < self.minItemWidth {
                width = self.minItemWidth
            }
            button.frame = CGRectMake(x, 0.0, width, self.frame.size.height)
            x += width + self.itemMargin
        }
        
        self.scrollView.contentSize = CGSizeMake(x, self.scrollView.frame.height)
        
        if self.frame.size.width > x {
            self.scrollView.frame.origin.x = (self.frame.size.width - x) / 2.0
            self.scrollView.frame.size.width = x
        } else {
            self.scrollView.frame.origin.x = 0.0
            self.scrollView.frame.size.width = self.frame.size.width
        }
    }
    
    public func changeParentScrollView(parentScrollView: UIScrollView, selectedIndex: Int, totalVCCount: Int) {
        self.selectedIndex = selectedIndex
        
        let oldX = CGFloat(selectedIndex) * parentScrollView.frame.size.width
        let scrollingTowards = parentScrollView.contentOffset.x > oldX
        let targetIndex = (scrollingTowards == true) ? selectedIndex + 1 : selectedIndex - 1
        
        if targetIndex >= 0 && targetIndex < totalVCCount {
            let ratio = (parentScrollView.contentOffset.x - oldX) / parentScrollView.frame.size.width
            
            let normal = self.titleColor.getRGBAStruct()
            let highlighted = self.highlightedTitleColor.getRGBAStruct()
            
            let absRatio = fabs(ratio)
            let prevColor = UIColor(
                red: normal.red * absRatio + highlighted.red * (1.0 - absRatio),
                green: normal.green * absRatio + highlighted.green * (1.0 - absRatio),
                blue: normal.blue * absRatio + highlighted.blue * (1.0 - absRatio),
                alpha: normal.alpha * absRatio + highlighted.alpha * (1.0 - absRatio)
            )
            let nextColor = UIColor(
                red: normal.red * (1.0 - absRatio) + highlighted.red * absRatio,
                green: normal.green * (1.0 - absRatio) + highlighted.green * absRatio,
                blue: normal.blue * (1.0 - absRatio) + highlighted.blue * absRatio,
                alpha: normal.alpha * (1.0 - absRatio) + highlighted.alpha * absRatio
            )
            
            let previosSelectedButton = self.buttons[selectedIndex]
            let nextSelectedButton = self.buttons[targetIndex]
            previosSelectedButton.setTitleColor(prevColor, forState: .Normal)
            nextSelectedButton.setTitleColor(nextColor, forState: .Normal)
            
            let previousItemContentOffsetX = self.contentOffsetForSelectedItemAtIndex(selectedIndex).x
            let nextItemContentOffsetX = self.contentOffsetForSelectedItemAtIndex(targetIndex).x
            if scrollingTowards == true {
                self.scrollView.contentOffset = CGPointMake(
                    previousItemContentOffsetX + (nextItemContentOffsetX - previousItemContentOffsetX) * ratio,
                    0.0
                )
            } else {
                self.scrollView.contentOffset = CGPointMake(
                    previousItemContentOffsetX - (nextItemContentOffsetX - previousItemContentOffsetX) * ratio,
                    0.0
                )
            }
        }
    }
}

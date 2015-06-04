//
//  ARNPageContainerTabView.swift
//  ARNPageContainer-Swift
//
//  Created by xxxAIRINxxx on 2015/01/20.
//  Copyright (c) 2015 Airin. All rights reserved.
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
                var button = self.buttons[index]
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
            for button in self.scrollView.subviews {
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
                var button = self.itemButton()
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
        scrollView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        scrollView.scrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    lazy var backGroundImageiew : UIImageView = {
        var backGroundImageiew = UIImageView(frame: self.bounds)
        backGroundImageiew.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        return backGroundImageiew
    }()
    
    var buttons : [UIButton] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.backGroundImageiew)
        self.addSubview(self.scrollView)
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cleanup() {
        for button in self.scrollView.subviews {
            button.removeFromSuperview()
        }
        self.buttons.removeAll(keepCapacity: false)
    }
    
    func itemButton() -> UIButton {
        var button = UIButton(frame: CGRectMake(0.0, 0.0, self.minItemWidth, self.frame.height))
        button.titleLabel?.font = self.font
        button.setTitleColor(self.titleColor, forState: .Normal)
        button.addTarget(self, action: Selector("buttonTapped:"), forControlEvents: .TouchUpInside)
        self.scrollView.addSubview(button)
        
        return button
    }
    
    func resetButtonTitleColor() {
        for index in 0..<self.buttons.count {
            var button = self.buttons[index]
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
            var button = self.buttons[index]
            let fontAttr = NSDictionary(object: button.titleLabel!.font, forKey: NSFontAttributeName)
            var width = NSString(string: button.titleLabel!.text!).sizeWithAttributes(fontAttr as [NSObject : AnyObject]).width
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
        struct RGBA {
            var red : CGFloat = 0.0
            var green : CGFloat = 0.0
            var blue : CGFloat = 0.0
            var alpha  : CGFloat = 0.0
        }
        
        self.selectedIndex = selectedIndex
        
        let oldX = CGFloat(selectedIndex) * parentScrollView.frame.size.width
        let scrollingTowards = parentScrollView.contentOffset.x > oldX
        let targetIndex = (scrollingTowards == true) ? selectedIndex + 1 : selectedIndex - 1
        
        if targetIndex >= 0 && targetIndex < totalVCCount {
            let ratio = (parentScrollView.contentOffset.x - oldX) / parentScrollView.frame.size.width
            
            var normal = RGBA()
            var highlighted = RGBA()
            self.getColor(&normal.red, green: &normal.green, blue: &normal.blue, alpha: &normal.alpha, fromColor: self.titleColor)
            self.getColor(&highlighted.red, green: &highlighted.green, blue: &highlighted.blue, alpha: &highlighted.alpha, fromColor: self.highlightedTitleColor)
            
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
            
            var previosSelectedButton = self.buttons[selectedIndex]
            var nextSelectedButton = self.buttons[targetIndex]
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
    
    func getColor(inout red : CGFloat, inout green : CGFloat, inout blue : CGFloat, inout alpha : CGFloat, fromColor : UIColor) {
        let components = CGColorGetComponents(fromColor.CGColor)
        let colorSpaceModel = CGColorSpaceGetModel(CGColorGetColorSpace(fromColor.CGColor))
        
        if colorSpaceModel.value == kCGColorSpaceModelRGB.value && CGColorGetNumberOfComponents(fromColor.CGColor) == 4 {
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
        } else if colorSpaceModel.value == kCGColorSpaceModelMonochrome.value && CGColorGetNumberOfComponents(fromColor.CGColor) == 2 {
            red = components[0]
            green = components[0]
            blue = components[0]
            alpha = components[1]
        } else {
            red = components[0]
            green = components[0]
            blue = components[0]
            alpha = components[0]
        }
    }
}

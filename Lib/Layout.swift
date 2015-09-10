//
//  Layout.swift
//  ARNPageContainer-Swift
//
//  Created by xxxAIRINxxx on 2015/01/27.
//  Copyright (c) 2015 xxxAIRINxxx. All rights reserved.
//

import UIKit

public extension UIView {
    
    public func checkTranslatesAutoresizing(withView: UIView?, toView: UIView?) {
        if self.translatesAutoresizingMaskIntoConstraints() == true {
            self.setTranslatesAutoresizingMaskIntoConstraints(false)
        }
        
        if let withView = withView {
            if withView.translatesAutoresizingMaskIntoConstraints() == true {
                withView.setTranslatesAutoresizingMaskIntoConstraints(false)
            }
        }
        
        if let toView = toView {
            if toView.translatesAutoresizingMaskIntoConstraints() == true {
                toView.setTranslatesAutoresizingMaskIntoConstraints(false)
            }
        }
    }
    
    public func arn_addPin(withView:UIView, attribute:NSLayoutAttribute, toView:UIView?, constant:CGFloat) -> NSLayoutConstraint {
        checkTranslatesAutoresizing(withView, toView: toView)
        return arn_addPinConstraint(self, withItem: withView, toItem: toView, attribute: attribute, constant: constant)
    }
    
    public func arn_addPin(withView:UIView, isWithViewTop:Bool, toView:UIView?, isToViewTop:Bool, constant:CGFloat) -> NSLayoutConstraint {
        checkTranslatesAutoresizing(withView, toView: toView)
        return arn_addConstraint(
            self,
            relation: .Equal,
            withItem: withView,
            withAttribute: (isWithViewTop == true ? .Top : .Bottom),
            toItem: toView,
            toAttribute: (isToViewTop == true ? .Top : .Bottom),
            constant: constant
        )
    }
    
    public func arn_allPin(subView: UIView) {
        checkTranslatesAutoresizing(subView, toView: nil)
        arn_addPinConstraint(self, withItem: subView, toItem: self, attribute: .Top, constant: 0.0)
        arn_addPinConstraint(self, withItem: subView, toItem: self, attribute: .Bottom, constant: 0.0)
        arn_addPinConstraint(self, withItem: subView, toItem: self, attribute: .Left, constant: 0.0)
        arn_addPinConstraint(self, withItem: subView, toItem: self, attribute: .Right, constant: 0.0)
    }
    
    // MARK: NSLayoutConstraint
    
    public func arn_addPinConstraint(parentView: UIView, withItem:UIView, toItem:UIView?, attribute:NSLayoutAttribute, constant:CGFloat) -> NSLayoutConstraint {
        return arn_addConstraint(
            parentView,
            relation: .Equal,
            withItem: withItem,
            withAttribute: attribute,
            toItem: toItem,
            toAttribute: attribute,
            constant: constant
        )
    }
    
    public func arn_addWidthConstraint(view: UIView, constant:CGFloat) -> NSLayoutConstraint {
        return arn_addConstraint(
            view,
            relation: .Equal,
            withItem: view,
            withAttribute: .Width,
            toItem: nil,
            toAttribute: .Width,
            constant: constant
        )
    }
    
    public func arn_addHeightConstraint(view: UIView, constant:CGFloat) -> NSLayoutConstraint {
        return arn_addConstraint(
            view,
            relation: .Equal,
            withItem: view,
            withAttribute: .Height,
            toItem: nil,
            toAttribute: .Height,
            constant: constant
        )
    }
    
    public func arn_addConstraint(addView: UIView, relation: NSLayoutRelation, withItem:UIView, withAttribute:NSLayoutAttribute, toItem:UIView?, toAttribute:NSLayoutAttribute, constant:CGFloat) -> NSLayoutConstraint {
        var constraint = NSLayoutConstraint(
            item: withItem,
            attribute: withAttribute,
            relatedBy: relation,
            toItem: toItem,
            attribute: toAttribute,
            multiplier: 1.0,
            constant: constant
        )
        
        addView.addConstraint(constraint)
        
        return constraint
    }
}

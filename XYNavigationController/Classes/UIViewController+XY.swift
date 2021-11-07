//
//  UIViewController+XY.swift
//  XYNavigationBar
//
//  Created by yuan188 on 2021/10/21.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import UIKit

private var kXYNavigationBarAttributesKey = "XYNavigationBarAttributes"
private var kXYNavigationSwipeBackEnabledKey = "XYNavigationSwipeBackEnabledKey"
private var kXYNavigationFullScreenSwipeBackEnabledKey = "XYNavigationFullScreenSwipeBackEnabledKey"

extension UIViewController {
    /// UIViewController 各自对应NavigationBar的属性值
    public var xy_navigationBarAttributes: XYNavigationBar.Attributes {
        if let item = objc_getAssociatedObject(self, &kXYNavigationBarAttributesKey) as? XYNavigationBar.Attributes {
            return item
        } else {
            let item = XYNavigationBar.Attributes(base: self, attributes: XYNavigationBar.attributes)
            objc_setAssociatedObject(self, &kXYNavigationBarAttributesKey, item, .OBJC_ASSOCIATION_RETAIN)

            return item
        }
    }

    /// 是否允许左滑返回
    /// 默认值：true
    public var xy_isSwipeBackEnabled: Bool {
        get {
            return (objc_getAssociatedObject(self, &kXYNavigationSwipeBackEnabledKey) as? Bool) ?? true
        }
        set {
            objc_setAssociatedObject(self, &kXYNavigationSwipeBackEnabledKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }

    /// 是否允许全屏左滑返回
    /// 默认值：false
    public var xy_isFullScreenSwipeBackEnabled: Bool {
        get {
            return (objc_getAssociatedObject(self, &kXYNavigationFullScreenSwipeBackEnabledKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &kXYNavigationFullScreenSwipeBackEnabledKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

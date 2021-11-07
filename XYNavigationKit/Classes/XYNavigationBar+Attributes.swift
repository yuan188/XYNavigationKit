//
//  XYNavigationBarAttributes.swift
//  XYNavigationKit
//
//  Created by yuan188 on 2021/10/23.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation

extension XYNavigationBar {
    public class Attributes {
        private unowned let base: UIViewController?

        var backgroundAttributes: BackgroundAttributes

        init() {
            self.base = nil
            self.backgroundAttributes = BackgroundAttributes()
        }

        init(base: UIViewController?, attributes: Attributes) {
            self.base = base

            self.style = attributes.style
            self.backgroundAttributes = attributes.backgroundAttributes
        }

        /// bar 样式，默认为default
        public var style: UIBarStyle = .default {
            didSet {
                updateBarIfNeed()
            }
        }

        public var tintColor: UIColor?
        public var titleTextAttributes: [NSAttributedString.Key : Any]?
    }

    struct BackgroundAttributes {
        var isTranslucent: Bool = true

        var color: UIColor? = .white
        var image: UIImage?

        var alpha: CGFloat = 1.0
        var isHidden: Bool = false

        var isShadowHidden: Bool = false
        var shadowImage: UIImage?
        var shadowColor: UIColor? = UIColor(red: 0, green: 0, blue: 0, alpha: 77.0/255)

        var isIgnoreAlpha: Bool = false
    }
}

extension XYNavigationBar.Attributes {
    private func updateBarIfNeed() {
        guard let navigationController = base?.navigationController,
              navigationController.topViewController == base,
              let navigationBar = navigationController.navigationBar as? XYNavigationBar else {
                  return
              }

        navigationBar.setAttributes(self)
        navigationController.setNeedsStatusBarAppearanceUpdate()
    }

    /// 是否忽略alpha值
    /// backgroundColor、alpha 将被忽略掉
    /// VC edgesForExtendedLayout 包含 top 时，需要设置为true
    var isIgnoreBackgroundAlpha: Bool {
        get {
            backgroundAttributes.isIgnoreAlpha
        }
        set {
            backgroundAttributes.isIgnoreAlpha = newValue
            updateBarIfNeed()
        }
    }

    /// 是否有半透明虚化效果
    /// backgroundColor, backgroundImage 无alpha通道时，透明度将默认为 0.85
    /// 背景 alpha < 1 时，将没有虚化效果
    /// 默认值：true
    public var isTranslucent: Bool {
        get {
            backgroundAttributes.isTranslucent
        }
        set {
            backgroundAttributes.isTranslucent = newValue
            updateBarIfNeed()
        }
    }

    /// bar 背景颜色，优先使用backgroundImage
    /// 默认值：white
    public var backgroundColor: UIColor? {
        get {
            backgroundAttributes.color
        }
        set {
            backgroundAttributes.color = newValue
            updateBarIfNeed()
        }
    }

    /// bar 背景图
    /// 默认值：nil
    public var backgroundImage: UIImage? {
        get {
            backgroundAttributes.image
        }
        set {
            backgroundAttributes.image = newValue
            updateBarIfNeed()
        }
    }

    /// bar 背景透明度
    /// 默认值：1.0，完全不透明
    /// < 0.01时，触摸事件将穿透
    public var backgroundAlpha: CGFloat {
        get {
            backgroundAttributes.alpha
        }
        set {
            backgroundAttributes.alpha = newValue
            updateBarIfNeed()
        }
    }

    /// bar 是否隐藏背景
    /// 默认值：false
    /// true时，触摸事件将穿透
    public var isBackgroundHidden: Bool {
        get {
            backgroundAttributes.isHidden
        }
        set {
            backgroundAttributes.isHidden = newValue
            updateBarIfNeed()
        }
    }

    /// bar 底部阴影线是否隐藏
    /// 默认值：false
    public var isShadowHidden: Bool {
        get {
            backgroundAttributes.isShadowHidden
        }
        set {
            backgroundAttributes.isShadowHidden = newValue
            updateBarIfNeed()
        }
    }

    /// bar 底部阴影线 图片
    /// 默认值：nil
    public var shadowImage: UIImage? {
        get {
            backgroundAttributes.shadowImage
        }
        set {
            backgroundAttributes.shadowImage = newValue
            updateBarIfNeed()
        }
    }

    /// bar 底部阴影线颜色，优先使用 shadowImage
    /// 默认值：nil
    public var shadowColor: UIColor? {
        get {
            backgroundAttributes.shadowColor
        }
        set {
            backgroundAttributes.shadowColor = newValue
            updateBarIfNeed()
        }
    }
}

extension XYNavigationBar {
    public static let attributes = Attributes()
}

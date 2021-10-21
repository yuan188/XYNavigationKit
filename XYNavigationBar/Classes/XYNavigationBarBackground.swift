//
//  XYNavigationBarBackground.swift
//  XYNavigationBar
//
//  Created by yuan188 on 2021/10/23.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import Foundation
import UIKit

class XYNavigationBarBackground: UIView {
    private let shadowImageView = UIImageView()

    private let blurView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))

        if let subclass = NSClassFromString("_UIVisualEffectSubview") {
            for view in effectView.subviews {
                if view.isMember(of: subclass) {
                    view.removeFromSuperview()
                }
            }
        }

        return effectView
    }()

    private let backgroundImageView = UIImageView()

    private var _backgroundColor: UIColor?

    /// 是否有半透明虚化效果
    /// backgroundColor, backgroundImage 无alpha通道时，将默认为 0.85
    /// 背景 alpha < 1 时，失效
    var isTranslucent: Bool {
        get {
            !blurView.isHidden
        }
        set {
            blurView.isHidden = !newValue
        }
    }

    /// 背景颜色
    override var backgroundColor: UIColor? {
        get {
            _backgroundColor
        }
        set {
            _backgroundColor = newValue
        }
    }

    /// 背景图
    var backgroundImage: UIImage?

    /// 是否忽略alpha
    var isIgnoreAlpha: Bool = false

    /// 是否隐藏底部阴影横线
    var isShadowHidden: Bool {
        get {
            return shadowImageView.isHidden
        }
        set {
            shadowImageView.isHidden = newValue
        }
    }

    /// 底部阴影横线
    var shadowImage: UIImage?

    /// 底部阴影横线颜色
    var shadowColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)

        updateLayout()
        addSubview(blurView)
        addSubview(backgroundImageView)
        addSubview(shadowImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }

    func setAttributes(_ attributes: XYNavigationBar.BackgroundAttributes) {
        isTranslucent = attributes.isTranslucent

        backgroundColor = attributes.color
        backgroundImage = attributes.image

        alpha = attributes.isIgnoreAlpha ? 1.0 : attributes.alpha

        isHidden = attributes.isHidden

        isShadowHidden = attributes.isShadowHidden
        shadowImage = attributes.shadowImage
        shadowColor = attributes.shadowColor
//        isIgnoreAlpha = attributes.isIgnoreAlpha

        updateShadow()
        updateBackgroundView()
    }

    private func updateLayout() {
        blurView.frame = bounds
        backgroundImageView.frame = bounds

        let lineHeight = 1 / UIScreen.main.scale
        shadowImageView.frame = CGRect(x: 0, y: bounds.height - lineHeight, width: bounds.width, height: lineHeight)
    }

    private func updateShadow() {
        shadowImageView.image = shadowImage
        if shadowImage == nil {
            shadowImageView.backgroundColor = shadowColor
        } else {
            shadowImageView.backgroundColor = nil
        }
    }

    private func updateBackgroundView() {
        backgroundImageView.image = backgroundImage
        if backgroundImage == nil {
            backgroundImageView.backgroundColor = isIgnoreAlpha ? backgroundColor?.withAlphaComponent(1.0) : backgroundColor
        } else {
            backgroundImageView.backgroundColor = isIgnoreAlpha ? (backgroundColor?.withAlphaComponent(1.0) ?? .white): nil
        }

        updateBackgroundViewAlpha()
    }

    private func updateBackgroundViewAlpha() {
        guard isTranslucent, !isIgnoreAlpha else {
            backgroundImageView.alpha = 1.0
            return
        }

        let hasAlpha: Bool
        if let cgImage = backgroundImage?.cgImage {
            let alphaInfos: [CGImageAlphaInfo] = [.first, .last, .premultipliedFirst, .premultipliedLast]
            hasAlpha = alphaInfos.contains(cgImage.alphaInfo)
        } else if let color = backgroundColor {
            var alpha: CGFloat = 1.0
            color.getWhite(nil, alpha: &alpha)

            hasAlpha = alpha < 1.0
        } else {
            hasAlpha = false
        }

        backgroundImageView.alpha = hasAlpha ? 1.0 : 0.85
    }
}

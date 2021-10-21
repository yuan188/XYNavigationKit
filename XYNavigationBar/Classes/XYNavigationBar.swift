//
//  XYNavigationBar.swift
//  XYNavigationBar
//
//  Created by yuan188 on 2021/10/21.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import UIKit

public class XYNavigationBar: UINavigationBar {
    private lazy var backgroundView: XYNavigationBarBackground = makeBackgroundView()

    public override var backgroundColor: UIColor? {
        get {
            backgroundView.backgroundColor
        }
        set {
            backgroundView.backgroundColor = newValue
        }
    }

    public override var isTranslucent: Bool {
        get {
            return true
        }
        set {
            // do nothing isTranslucent = true
        }
    }

    var isBackgroundHidden: Bool {
        get {
            backgroundView.isHidden
        }
        set {
            backgroundView.isHidden = true
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        if let bgSuperview = backgroundView.superview {
            backgroundView.frame = bgSuperview.bounds
        } else {
            addBackgroundViewIfNeed()
        }
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }

        let viewType = type(of: view)
        let viewName = NSStringFromClass(viewType).replacingOccurrences(of: "_", with: "")

        if ["UINavigationBarContentView", "UIButtonBarStackView", "XYNavigationBar"].contains(viewName),
           (isBackgroundHidden || backgroundView.alpha < 0.01) {
            return nil
        } else {
            return view
        }
    }

    func setAttributes(_ attributes: Attributes, withoutBackground: Bool = false) {
        barStyle = attributes.style
        tintColor = attributes.tintColor

        // title 颜色适配
        if var textAttributes = attributes.titleTextAttributes {
            if textAttributes[.foregroundColor] == nil {
                textAttributes[.foregroundColor] = attributes.style == .black ? UIColor.white : UIColor.black
            }

            titleTextAttributes = textAttributes
        } else {
            titleTextAttributes = [.foregroundColor: attributes.style == .black ? UIColor.white : UIColor.black]
        }

        if #available(iOS 13.0, *) {
            let appearance = standardAppearance
            appearance.titleTextAttributes = titleTextAttributes ?? [:]
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
        }

        if !withoutBackground {
            backgroundView.setAttributes(attributes.backgroundAttributes)
        }

        addBackgroundViewIfNeed()
    }

    func convertBackgroundFrame(to view: UIView?) -> CGRect {
        let rect = backgroundView.frame
        guard let bgsuperview = backgroundView.superview else {
            return rect
        }

        return bgsuperview.convert(rect, to: view)
    }

    // MARK: - private
    private func makeBackgroundView() -> XYNavigationBarBackground {
        super.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            standardAppearance = appearance
            scrollEdgeAppearance = appearance
        } else {
            super.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
            super.shadowImage = UIImage()
        }

        let view = XYNavigationBarBackground()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return view
    }

    private func addBackgroundViewIfNeed() {
        guard backgroundView.superview == nil,
              let bgSuperview = subviews.first else {
                  return
              }

        backgroundView.frame = bgSuperview.bounds

        bgSuperview.clipsToBounds = true
        bgSuperview.insertSubview(backgroundView, at: 0)
    }
}

extension XYNavigationBar {
    var backTitle: String {
        guard let contentViewClass = NSClassFromString("_UINavigationBarContentView"),
              let barButtonClass = NSClassFromString("_UIButtonBarButton"),
              let contentView = subviews.first(where: { $0.isKind(of: contentViewClass) }),
              let backButton = contentView.subviews.first(where: { $0.isKind(of: barButtonClass) }),
              let titleButton = backButton.value(forKeyPath: "visualProvider.titleButton") as? UIButton else {
            return ""
        }

        return titleButton.titleLabel?.text ?? ""
    }
}

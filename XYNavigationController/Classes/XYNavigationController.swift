//
//  XYNavigationController.swift
//  XYNavigationBar
//
//  Created by yuan188 on 2021/10/21.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import UIKit

open class XYNavigationController: UINavigationController {
    private lazy var xyDelegate: XYNavigationControllerDelegate = {
        let delegate = XYNavigationControllerDelegate(navigationController: self)
        delegate.proxyDelegate = self.delegate

        return delegate
    }()

    public override init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass ?? XYNavigationBar.self, toolbarClass: nil)
    }

    public override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: XYNavigationBar.self, toolbarClass: nil)
        viewControllers = [rootViewController]
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    var xy_navigationBar: XYNavigationBar {
        return navigationBar as! XYNavigationBar
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isTranslucent = true
        originInteractivePopGestureRecognizer?.isEnabled = false
        delegate = xyDelegate
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let barStyle = topViewController?.xy_navigationBarAttributes.style else {
            return .default
        }

        return barStyle == .black ? .lightContent : .default
    }

    // 代理处理delegate
    open override var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            if newValue is XYNavigationControllerDelegate {
                super.delegate = newValue
            } else {
                xyDelegate.proxyDelegate = newValue
            }
        }
    }

    open override var interactivePopGestureRecognizer: UIGestureRecognizer? {
        return xyDelegate
    }

    var originInteractivePopGestureRecognizer: UIGestureRecognizer? {
        return super.interactivePopGestureRecognizer
    }

    func updateNavigationBar(viewController: UIViewController, withoutBackground: Bool = false) {
        let isIgnoreBackgroundAlpha = !viewController.edgesForExtendedLayout.contains(.top)
        viewController.xy_navigationBarAttributes.isIgnoreBackgroundAlpha = isIgnoreBackgroundAlpha
        xy_navigationBar.setAttributes(viewController.xy_navigationBarAttributes, withoutBackground: withoutBackground)

        setNeedsStatusBarAppearanceUpdate()
    }
}

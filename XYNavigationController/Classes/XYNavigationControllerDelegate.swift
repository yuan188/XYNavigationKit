//
//  XYNavigationControllerDelegate.swift
//  XYNavigationBar
//
//  Created by yuan188 on 2021/10/21.
//  Copyright (c) 2021 yuan188. All rights reserved.
//

import UIKit

class XYNavigationControllerDelegate: UIScreenEdgePanGestureRecognizer, UINavigationControllerDelegate {
    private lazy var fromBarBackground = XYNavigationBarBackground()
    private lazy var toBarBackground = XYNavigationBarBackground()

    private let fullScreenPanGestureRecognizer = UIPanGestureRecognizer()

    private var isOriginBackgroundHidden: Bool?

    unowned let navigationController: XYNavigationController
    let navigationBar: XYNavigationBar

    weak var proxyDelegate: UINavigationControllerDelegate?

    init(navigationController: XYNavigationController) {
        self.navigationController = navigationController
        navigationBar = navigationController.xy_navigationBar

        super.init(target:nil, action:nil)

        edges = .left
        delegate = self
        navigationController.view.addGestureRecognizer(self)
        addTarget(self, action: #selector(handleNavigationTransition(_:)))

        // 可实现整体滑动返回
        fullScreenPanGestureRecognizer.addTarget(self, action: #selector(handleNavigationTransition(_:)))
        fullScreenPanGestureRecognizer.delegate = self
        navigationController.view.addGestureRecognizer(fullScreenPanGestureRecognizer)
    }

    // MARK: - proxy
    func isProxySelector(_ selector: Selector) -> Bool {
        let proxySelectors = [#selector(navigationController(_:willShow:animated:)),
                              #selector(navigationController(_:didShow:animated:))
        ]

        return !proxySelectors.contains(selector)
    }

    override func responds(to aSelector: Selector!) -> Bool {
        if let proxyDelegate = proxyDelegate, isProxySelector(aSelector) {
            return proxyDelegate.responds(to: aSelector)
        } else {
            return super.responds(to: aSelector)
        }
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return isProxySelector(aSelector) ? proxyDelegate : nil
    }

    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        proxyDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)

        guard let coordinator = navigationController.transitionCoordinator,
              let fromVC = coordinator.viewController(forKey: .from),
              let toVC = coordinator.viewController(forKey: .to) else {
                  return
              }

        self.navigationController.updateNavigationBar(viewController: viewController, withoutBackground: true)
        showFakeBarBackground(fromVC: fromVC, toVC: toVC)

        let isPush = navigationController.viewControllers.contains(where: { fromVC == $0 })
        if isPush {
            updatePrevBackItem(vc: toVC)
        } else {
            updateViewControllerBackItem(vc: toVC, from: fromVC)
        }

        coordinator.animate { _ in

        } completion: { [weak self] context in
            guard let strongSelf = self else {
                return
            }

            let targetVC = context.isCancelled ? fromVC : toVC
            strongSelf.resetFakeBarBackground(toVC: targetVC)
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        proxyDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)

        if !animated {
            self.navigationController.updateNavigationBar(viewController: viewController)
            updatePrevBackItem(vc: viewController)
        }
    }

    func showFakeBarBackground(fromVC: UIViewController, toVC: UIViewController) {
        isOriginBackgroundHidden = navigationBar.isBackgroundHidden
        navigationBar.isBackgroundHidden = true

        addFakeBarBackground(fromBarBackground, vc: fromVC)
        addFakeBarBackground(toBarBackground, vc: toVC)
    }

    func resetFakeBarBackground(toVC: UIViewController) {
        if let isOriginBackgroundHidden = isOriginBackgroundHidden {
            navigationController.xy_navigationBar.isBackgroundHidden = isOriginBackgroundHidden
        }
        isOriginBackgroundHidden = nil

        fromBarBackground.removeFromSuperview()
        toBarBackground.removeFromSuperview()

        navigationController.updateNavigationBar(viewController: toVC)
    }

    func addFakeBarBackground(_ barBackground: XYNavigationBarBackground, vc: UIViewController) {
        barBackground.setAttributes(vc.xy_navigationBarAttributes.backgroundAttributes)

        var bgframe = navigationBar.convertBackgroundFrame(to: vc.view)

        // 依赖scrollView情况
        if let scrollView = vc.view as? UIScrollView,
            scrollView.contentOffset.y == 0 {
            bgframe.origin.y = -bgframe.size.height
        }

        if !vc.edgesForExtendedLayout.contains(.top) {
            vc.view.clipsToBounds = false
        }

        barBackground.frame = bgframe
        vc.view.addSubview(barBackground)
    }

    func updateViewControllerBackItem(vc: UIViewController, from: UIViewController) {
        if let backBarButtonItem = vc.navigationItem.backBarButtonItem {
            backBarButtonItem.tintColor = from.xy_navigationBarAttributes.tintColor
        } else {
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = navigationBar.backTitle
            backBarButtonItem.tintColor = from.xy_navigationBarAttributes.tintColor
            vc.navigationItem.backBarButtonItem = backBarButtonItem
        }
    }

    func updatePrevBackItem(vc: UIViewController) {
        var isFound = false
        var prevVC: UIViewController?
        for currentVC in navigationController.viewControllers {
            if currentVC == vc {
                isFound = true
                break
            }

            prevVC = currentVC
        }

        if isFound, let prevVC = prevVC,
           let backBarButtonItem = prevVC.navigationItem.backBarButtonItem{
            backBarButtonItem.tintColor = vc.xy_navigationBarAttributes.tintColor
        }
    }
}

extension XYNavigationControllerDelegate: UIGestureRecognizerDelegate {
    @objc func handleNavigationTransition(_ panGesture: UIScreenEdgePanGestureRecognizer) {
        if let target = navigationController.originInteractivePopGestureRecognizer?.delegate {
            target.perform(#selector(handleNavigationTransition(_:)), with: panGesture)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard navigationController.viewControllers.count > 1 else {
            return false
        }

        if gestureRecognizer == self {
            return navigationController.topViewController?.xy_isSwipeBackEnabled ?? true
        } else if gestureRecognizer == fullScreenPanGestureRecognizer {
            let isEnable = navigationController.topViewController?.xy_isFullScreenSwipeBackEnabled ?? false
            let translation = fullScreenPanGestureRecognizer.translation(in: gestureRecognizer.view)
            return isEnable && translation.x > 0
        } else {
            return false
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) && !otherGestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self)
    }
}

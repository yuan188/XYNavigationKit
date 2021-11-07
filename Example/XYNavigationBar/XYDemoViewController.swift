//
//  XYDemoViewController.swift
//  XYNavigationBar_Example
//
//  Created by yuan188 on 2021/10/22.
//  Copyright © 2021 yuan188. All rights reserved.
//

import UIKit
import XYNavigationController

class XYDemoViewController: UITableViewController {
    private var isDebugCurrentVC: Bool

    let kSettingsSection = 0

    let kColorSection = 1
    let kImageSection = 2
    let colors: [UIColor] = [.white, .red, .yellow, .green, .blue, .black]
    let images: [UIImage?] = [UIImage(named: "bar_image")]

    var barConfigs: [XYBarConfig: Bool] = [:]
    var transparent: CGFloat = 0.0

    enum XYBarConfig: CaseIterable, Hashable {
        case shadow
        case isTranslucent
        case barStyle
        case isHide
        case transparent

        var title: String {
            switch self {
            case .shadow:
                return "底下阴影线"
            case .isTranslucent:
                return "半透明高斯模糊"
            case .transparent:
                return "透明度"
            case .barStyle:
                return "UIBarStyle Black"
            case .isHide:
                return "隐藏"
            }
        }

        var defaultValue: Bool {
            switch self {
            case .isTranslucent:
                return true
            case .shadow, .barStyle, .isHide, .transparent:
                return false
            }
        }
    }

    init(isDebugCurrentVC: Bool = false) {
        self.isDebugCurrentVC = isDebugCurrentVC
        super.init(style: .grouped)
    }

    required init?(coder: NSCoder) {
        isDebugCurrentVC = false
        super.init(coder: coder)
        
        title = "Demo"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor(red: 0.968, green: 0.968, blue: 0.968, alpha: 1)
        tableView.rowHeight = 44

        let imageView = UIImageView(image: UIImage(named: "lakeside_sunset"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        tableView.tableHeaderView = imageView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 300))

        let rightButton = UIBarButtonItem(title: "配置当前VC", style: .plain, target: self, action: #selector(rightButtonClicked(_:)))
        rightButton.title = isDebugCurrentVC ? "配置下个VC" : "配置当前VC"
        navigationItem.rightBarButtonItem = rightButton
    }

    @objc func rightButtonClicked(_ button: UIBarButtonItem) {
        isDebugCurrentVC = !isDebugCurrentVC
        button.title = isDebugCurrentVC ? "配置下个VC" : "配置当前VC"

        barConfigs.removeAll()
        transparent = 0.0
        
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kColorSection {
            return colors.count
        } else if section == kImageSection {
            return images.count
        } else {
            return XYBarConfig.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let index = indexPath.row

        if indexPath.section == kColorSection {
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = colors[index]
        } else if indexPath.section == kImageSection {
            cell.accessoryType = .disclosureIndicator
            cell.backgroundView = UIImageView(image: images[index])
        } else {
            cell.selectionStyle = .none

            let config = XYBarConfig.allCases[index]
            cell.textLabel?.text = config.title

            if config == .transparent {
                let slider = UISlider(frame: CGRect(x: 0, y: 0, width: 2 / 3 * UIScreen.main.bounds.width, height: 60))
                slider.maximumValue = 1
                slider.minimumValue = 0
                slider.value = 0

                slider.tag = index
                slider.addTarget(self, action: #selector(transparentValueChanged(_:)), for: .valueChanged)
                cell.accessoryView = slider
            } else {
                let switchView = UISwitch()
                switchView.tag = index
                switchView.isOn = config.defaultValue
                switchView.addTarget(self, action: #selector(configValueChanged(_:)), for: .valueChanged)
                cell.accessoryView = switchView
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row

        if isDebugCurrentVC {
            if indexPath.section == kColorSection {
                xy_navigationBarAttributes.backgroundImage = nil
                xy_navigationBarAttributes.backgroundColor = colors[index]
            } else if indexPath.section == kImageSection {
                xy_navigationBarAttributes.backgroundImage = images[index]
            }
        } else {
            if indexPath.section == kColorSection {
                let vc = XYDemoViewController()
                vc.title = "测试\(navigationController?.viewControllers.count ?? 0)"

                setCurrentBarConfigs(vc: vc)
                vc.xy_navigationBarAttributes.backgroundColor = colors[index]
                vc.xy_navigationBarAttributes.tintColor = colors[(index + 1) % colors.count]

                show(vc, sender: self)
            } else if indexPath.section == kImageSection {
                let vc = XYDemoViewController()
                setCurrentBarConfigs(vc: vc)
                vc.xy_navigationBarAttributes.backgroundImage = images[index]
                show(vc, sender: self)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let prefix = isDebugCurrentVC ? "当前" : "下一个"
        if section == kColorSection {
            return prefix + "VC Navigation Bar背景色"
        } else if section == kImageSection {
            return prefix + "VC Navigation Bar背景图"
        } else {
            return prefix + "VC配置"
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    @objc private func configValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        guard 0..<XYBarConfig.allCases.count ~= index else {
            return
        }

        let config = XYBarConfig.allCases[index]
        barConfigs[config] = sender.isOn

        if isDebugCurrentVC {
            setCurrentBarConfigs(vc: self)
        }
    }

    @objc private func transparentValueChanged(_ sender: UISlider) {
        transparent = CGFloat(sender.value)

        if isDebugCurrentVC {
            setCurrentBarConfigs(vc: self)
        }
    }

    func setCurrentBarConfigs(vc: UIViewController) {
        vc.xy_navigationBarAttributes.isShadowHidden = !(barConfigs[.shadow] ?? false)
        vc.xy_navigationBarAttributes.isTranslucent = barConfigs[.isTranslucent] ?? false
        vc.xy_navigationBarAttributes.isBackgroundHidden = barConfigs[.isHide] ?? false
        vc.xy_navigationBarAttributes.style = (barConfigs[.barStyle] ?? false) ? .black : .default

        vc.xy_navigationBarAttributes.backgroundAlpha = 1 - transparent
    }
}

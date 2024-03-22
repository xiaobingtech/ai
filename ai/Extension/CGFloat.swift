//
//  CGFloat+.swift
//  
//
//  Created by 范东 on 2022/5/10.
//

import Foundation
import UIKit

public extension CGFloat {
    static let screenW = Swift.min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    static let screenH = Swift.max(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height)
    static let navigationBarHeight = CGFloat(44)
    static let statusBarHeight = CGFloat(UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0)
    static let largeNavigationTitleHeight = CGFloat(96)
    static let topHeight = (statusBarHeight + navigationBarHeight)
    static let tabBarHeight = CGFloat(49 + (statusBarHeight > 20 ? 34 : 0))
    static let safeAreaBottomHeight = CGFloat(statusBarHeight > 20 ? 34 : 0)
    static let screenScale = UIScreen.main.scale
}

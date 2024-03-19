//
//  TabBarViewController.swift
//  
//
//  Created by 范东 on 2022/5/10.
//

import UIKit
import JXSegmentedView

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let vc = HomeViewController()
        //配置数据源
        let dataSource = JXSegmentedTitleDataSource()
        dataSource.isTitleColorGradientEnabled = true
        dataSource.titles = ["原创","当前最热","本月最热","10分钟以上","20分钟以上","本月收藏","收藏最多","最近加精","高清","上月最热","本月讨论"]
        dataSource.titleNormalColor = .init(dynamicProvider: { collection in
            if collection.userInterfaceStyle == .light {
                return .black
            }
            return .white
        })
        vc.segmentedDataSource = dataSource
        //配置指示器
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = JXSegmentedViewAutomaticDimension
        vc.segmentedView.indicators = [indicator]
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem = UITabBarItem(title: "首页", image: UIImage(systemName: "clock"), tag: 0)
        
        let searchVC = SearchViewController()
        let searchNav = UINavigationController(rootViewController: searchVC)
        searchNav.tabBarItem = UITabBarItem(title: "搜索", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        let setVC = ServerViewController()
        let setNav = UINavigationController(rootViewController: setVC)
        setNav.tabBarItem = UITabBarItem(title: "设置", image: UIImage(systemName: "gearshape.circle"), tag: 2)
        
        let webVC = WebViewController()
        let webNav = UINavigationController(rootViewController: webVC)
        webNav.tabBarItem = UITabBarItem(title: "网络", image: UIImage(systemName: "network"), tag: 3)
        
        viewControllers = [nav,setNav]
        tabBar.backgroundColor = .systemBackground
        
    }

}

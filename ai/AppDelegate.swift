//
//  AppDelegate.swift
//  ai
//
//  Created by 范小兵 on 2024/3/19.
//

import UIKit
import Tiercel

extension String {
    static let serverURL = "serverURL"
}

let appDelegate = UIApplication.shared.delegate as! AppDelegate

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sessionManager: SessionManager = {
        var configuration = SessionConfiguration()
        configuration.allowsCellularAccess = true
        let path = Cache.defaultDiskCachePathClosure("Tiercel")
        let cacahe = Cache("DownloadVC", downloadPath: path)
        let manager = SessionManager("DownloadVC", configuration: configuration, cache: cacahe, operationQueue: DispatchQueue(label: "com.xiaobingkj.SessionManager.operationQueue"))
        return manager
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: .init(x: 0, y: 0, width: .screenW, height: .screenH))
        let serverURL = UserDefaults.standard.string(forKey: .serverURL)
        if serverURL == nil {
            window?.rootViewController = ServerVC()
            NotificationCenter.default.addObserver(self, selector: #selector(receiveNoti), name: NSNotification.Name(rawValue: .serverURL), object: nil)
        }else{
            receiveNoti()
        }
        window?.makeKeyAndVisible()
        return true
    }
    
    @objc func receiveNoti(){
        window?.rootViewController = TabC()
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        sessionManager.completionHandler = completionHandler
    }

}


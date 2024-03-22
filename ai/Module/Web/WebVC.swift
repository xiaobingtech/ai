//
//  WebViewController.swift
//  
//
//  Created by 范东 on 2022/5/25.
//

import UIKit
import WebKit

class WebVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let serverURL = UserDefaults.standard.string(forKey: .serverURL) ?? ""
        webView.load(URLRequest(url: URL(string: serverURL)!))
    }
    

    lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        return webView
    }()

}

extension WebVC: WKNavigationDelegate{
    
}

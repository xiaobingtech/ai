//
//  SearchViewController.swift
//  
//
//  Created by 范东 on 2022/5/25.
//

import UIKit
import SwiftSoup
import SDWebImage
import AVKit
import JXSegmentedView
import MJRefresh
import Toast

class SearchVC: UIViewController {

    var dataArray = [ListModel]()
    // current document
    var document: Document = Document.init("")
    var detailDocument: Document = Document.init("")
    var page = 1
    var keyword = ""
    
    var URLStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        navigationItem.titleView = searchBar
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.addSubview(collectionView)
            collectionView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(CGFloat.topHeight)
            }
            MJRefreshNormalHeader { [weak self] in
              // load some data
                self?.headerRefresh()
            }.autoChangeTransparency(true)
            .link(to: collectionView)
            MJRefreshBackNormalFooter{ [weak self] in
                // load some data
                  self?.footerRefresh()
              }.autoChangeTransparency(true)
              .link(to: collectionView)
        }else{
            view.addSubview(tableView)
            tableView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.top.equalTo(CGFloat.topHeight)
            }
            MJRefreshNormalHeader { [weak self] in
              // load some data
                self?.headerRefresh()
            }.autoChangeTransparency(true)
              .link(to: tableView)
            MJRefreshBackNormalFooter{ [weak self] in
                // load some data
                  self?.footerRefresh()
              }.autoChangeTransparency(true)
              .link(to: tableView)
        }
    }
    
    func headerRefresh(){
        page = 1
        downloadHTML()
    }
    
    func footerRefresh(){
        page = page + 1
        downloadHTML()
    }
    
    
    func downloadHTML() {
        // url string to URL
        let serverURL = UserDefaults.standard.string(forKey: .serverURL) ?? ""
        let currentUrl = serverURL + "/search_result.php?search_id="
        let string = currentUrl+keyword+"&search_type=search_videos&page=\(page)"
        let string_new = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: string_new ?? "") else {
            // an error occurred
            view.makeToast("url格式不正确")
            return
        }
        DispatchQueue.global().async {
            do {
                // content of url
                let html = try String.init(contentsOf: url)
                // parse it into a Document
                self.document = try SwiftSoup.parse(html)
                // parse css query
                DispatchQueue.main.async {
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    self.parse()
                }
            } catch let error {
                // an error occurred
                DispatchQueue.main.async {
                    self.view.makeToast(error.localizedDescription)
                }
            }
        }
        

    }

    //Parse CSS selector
    func parse() {
        do {
                // 选择所有视频项的容器，这里假设每个视频项都在一个 'well well-sm videos-text-align' 类的 div 中
                let videoItems = try document.select("div.well.well-sm.videos-text-align")
                
                // 遍历每个视频项
                for item in videoItems {
                    // 提取视频链接
                    let videoLink = try item.select("a").attr("href")
                    
                    // 提取视频持续时间
                    let duration = try item.select("span.duration").text()
                    
                    // 提取视频标题
                    let title = try item.select("span.video-title").text()
                    
                    // 提取添加时间
                    let addTime = try (item.select("span.info:contains(添加时间)").first()?.parent()?.text().components(separatedBy: "添加时间:").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 提取作者
                    let author = try (item.select("span.info:contains(作者)").first()?.parent()?.text().components(separatedBy: "作者:").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 提取热度
                    let views = try (item.select("span.info:contains(热度)").first()?.text().components(separatedBy: "热度:").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 提取收藏
                    let favorites = try (item.select("span.info:contains(收藏)").first()?.text().components(separatedBy: "收藏:").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 提取留言
                    let comments = try (item.select("span.info:contains(留言)").first()?.text().components(separatedBy: "留言:").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 提取积分
                    let points = try (item.select("span.info:contains(积分)").first()?.text().components(separatedBy: "积分:").last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // 提取封面图片链接
                    let thumbnailUrl = try item.select("img.img-responsive").attr("src")
                    
                    // 打印提取的信息
                    dataArray.append(ListModel(title: title, videoLink: videoLink, duration: duration, addTime: addTime, author: author, views: views, favorites: favorites, comments: comments, points: points, thumbnailUrl: thumbnailUrl))
                }
            } catch Exception.Error(let type, let message) {
                print("解析错误: \(type) \(message)")
                self.view.makeToast("解析错误: \(type) \(message)")
            } catch {
                print("未知错误")
                self.view.makeToast("未知错误")
            }
        if UIDevice.current.userInterfaceIdiom == .pad {
            collectionView.reloadData()
            collectionView.mj_header?.endRefreshing()
            collectionView.mj_footer?.endRefreshing()
        }else{
            tableView.reloadData()
            tableView.mj_header?.endRefreshing()
            tableView.mj_footer?.endRefreshing()
        }
        
    }
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = self
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "输入关键词"
        return searchBar
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ListCell.classForCoder(), forCellReuseIdentifier: "ListCell")
        tableView.separatorStyle = .none
        return tableView
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ItemCell.classForCoder(), forCellWithReuseIdentifier: "ItemCell")
        return collectionView
    }()
    
    func downloadDetailHTML(model: ListModel, isPlay: Bool) {
        // url string to URL
        guard let url = URL(string: model.videoLink) else {
            // an error occurred
            view.makeToast("url格式不正确")
            return
        }

        DispatchQueue.global().async {
            do {
                // content of url
                let html = try String.init(contentsOf: url)
                // parse it into a Document
                self.detailDocument = try SwiftSoup.parse(html)
                DispatchQueue.main.async {
                    // parse css query
                    self.parseDetail(model: model, isPlay: isPlay)
                }
            } catch let error {
                // an error occurred
                self.view.makeToast(error.localizedDescription)
            }
        }

    }

    //Parse CSS selector
    func parseDetail(model: ListModel, isPlay: Bool) {
        do {
            // 将 HTML 内容加载到 SwiftSoup Document 对象中
            
            // 假设 JavaScript 代码位于 <script> 标签中，我们可以遍历所有的 <script> 标签
            let scriptElements = try detailDocument.select("script").array()
            
            for script in scriptElements {
                let scriptContent = try script.html()
                // 检查脚本内容是否包含特定的字符串
                if scriptContent.contains("document.write(strencode2(") {
                    print("找到的字符串: \(scriptContent)")
                    let encodeStr = scriptContent.components(separatedBy: "\"")[1]
                    
                    if let decodedString = encodeStr.removingPercentEncoding {
                        // 打印解码后的字符串
                        print("Decoded String: \(decodedString)")
                        let finalStr = decodedString.components(separatedBy: "\'")[1]
                        // 进一步提取 MP4 链接
                        // 这里假设链接位于 'src=' 后面，直到下一个单引号之前
                        let playerC = AVPlayerViewController()
                        let player = AVPlayer(url: URL(string: finalStr)!)
                        player.play()
                        playerC.player = player
                        present(playerC, animated: true)
                    } else {
                        print("Failed to decode URL")
                    }
                    
                    // 进一步处理或提取信息
                    // 这里你可以根据需要进行字符串操作，例如使用正则表达式提取特定格式的内容
                    
                    
                }
            }
        } catch Exception.Error(let type, let message) {
            print("解析错误: \(type) \(message)")
        } catch {
            print("未知错误")
        }

    }
    
}

extension SearchVC: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 {
            return
        }
        keyword = searchBar.text!
        searchBar.resignFirstResponder()
        downloadHTML()
    }
}

extension SearchVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        if indexPath.row < dataArray.count {
            let model = dataArray[indexPath.row]
            cell.model = model
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        250
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        downloadDetailHTML(model: dataArray[indexPath.row], isPlay: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: String(indexPath.row) as NSCopying) {
            nil
        } actionProvider: { (element) -> UIMenu in
            let copyAction = UIAction(title: "复制链接", image: UIImage(systemName: "doc.on.doc")) { action in
                self.downloadDetailHTML(model: self.dataArray[indexPath.row], isPlay: false)
            }
            return UIMenu(children:[copyAction])
        }

    }
}

extension SearchVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        if indexPath.item < dataArray.count {
            let model = dataArray[indexPath.item]
            cell.model = model
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: floor((.screenW - 5 * 20 ) / 4), height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        downloadDetailHTML(model: model, isPlay: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: String(indexPath.row) as NSCopying) {
            nil
        } actionProvider: { (element) -> UIMenu in
            let copyAction = UIAction(title: "复制链接", image: UIImage(systemName: "doc.on.doc")) { action in
                self.downloadDetailHTML(model: self.dataArray[indexPath.row], isPlay: false)
            }
            return UIMenu(children:[copyAction])
        }
    }
}

extension SearchVC: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}


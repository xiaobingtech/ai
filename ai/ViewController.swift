//
//  ViewController.swift
//  MyPlayground
//
//  Created by 范东 on 2022/5/10.
//

import UIKit
import SwiftSoup
import SDWebImage
import AVKit
import JXSegmentedView
import MJRefresh
import Toast

enum ListType {
    case Original
    case CurrentHotest
    case MonthHotest
    case Minute10
    case Minute20
    case MonthCollect
    case MostCollect
    case RecentEssence
    case HD
    case LastMonthHotest
    case MonthComment
}

class ViewController: UIViewController {
    
    
    var dataArray = [ListModel]()
    // current document
    var document: Document = Document.init("")
    var detailDocument: Document = Document.init("")
    var currentUrl = ""
    var page = 1
    
    var URLStrings = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if UIDevice.current.userInterfaceIdiom == .pad {
            view.addSubview(collectionView)
            collectionView.snp.makeConstraints { make in
                make.right.bottom.left.equalToSuperview()
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
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
                make.right.bottom.left.equalToSuperview()
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
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
    
    
    var type = ListType.Original{
        didSet{
            let suffix = "&viewtype=basic"
            var serverURL = UserDefaults.standard.string(forKey: .serverURL) ?? ""
            serverURL = serverURL + "/v.php"
            switch type {
            case .Original:
                currentUrl = serverURL+"?category=or"
                break
            case .CurrentHotest:
                currentUrl = serverURL+"?category=hot"
                break
            case .MonthHotest:
                currentUrl = serverURL+"?category=top"
                break
            case .Minute10:
                currentUrl = serverURL+"?category=long"
                break
            case .Minute20:
                currentUrl = serverURL+"?category=longer"
                break
            case .MonthCollect:
                currentUrl = serverURL+"?category=tf"
                break
            case .MostCollect:
                currentUrl = serverURL+"?category=mf"
                break
            case .RecentEssence:
                currentUrl = serverURL+"?category=rf"
                break
            case .HD:
                currentUrl = serverURL+"?category=hd"
                break
            case .LastMonthHotest:
                currentUrl = serverURL+"?category=top&m=-1"
                break
            case .MonthComment:
                currentUrl = serverURL+"?category=md"
                break
            }
            currentUrl = currentUrl + suffix
            headerRefresh()
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
        view.makeToastActivity(.center)
        // url string to URL
        guard let url = URL(string: currentUrl+"&page=\(page)") else {
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
                    self.view.hideToastActivity()
                    
                    if self.page == 1 {
                        self.dataArray.removeAll()
                    }
                    self.parse()
                }
            } catch let error {
                // an error occurred
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
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
        view.makeToastActivity(.center)
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
                    self.view.hideToastActivity()
                    self.parseDetail(model: model, isPlay: isPlay)
                }
            } catch let error {
                // an error occurred
                DispatchQueue.main.async {
                    // parse css query
                    self.view.hideToastActivity()
                    self.view.makeToast(error.localizedDescription)
                }
                
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
                        if isPlay {
                            let playerC = AVPlayerViewController()
                            let player = AVPlayer(url: URL(string: finalStr)!)
                            player.play()
                            playerC.player = player
                            present(playerC, animated: true)
                        }else{
                            //TODO Download
                            appDelegate.sessionManager.download(finalStr, fileName: model.title + ".mp4")
                        }
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

extension ViewController: UITableViewDelegate,UITableViewDataSource{
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
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let downloadAction = UIAction(title: "下载", image: UIImage(systemName: "square.and.arrow.down")) { action in
                // 这里写点击“分享”后的逻辑
                self.downloadDetailHTML(model: self.dataArray[indexPath.row], isPlay: false)
            }
            
            // 创建并返回一个包含上述动作的菜单
            return UIMenu(title: "", children: [downloadAction])
        }
    }
}

extension ViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
        return CGSize(width: floor((.screenW - 5 * 15 ) / 4), height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        downloadDetailHTML(model: model, isPlay: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
            let downloadAction = UIAction(title: "下载", image: UIImage(systemName: "square.and.arrow.down")) { action in
                // 这里写点击“分享”后的逻辑
                self.downloadDetailHTML(model: self.dataArray[indexPath.item], isPlay: false)
            }
            
            // 创建并返回一个包含上述动作的菜单
            return UIMenu(title: "", children: [downloadAction])
        }
    }
}

extension ViewController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

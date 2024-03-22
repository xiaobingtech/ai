//
//  DownloadVC.swift
//  ai
//
//  Created by ybdjk on 2024/3/22.
//

import UIKit
import Tiercel
import AVKit

class DownloadVC: UIViewController {
    var sessionManager: SessionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "下载列表"
        sessionManager = appDelegate.sessionManager
        // 检查磁盘空间
        let free = FileManager.default.tr.freeDiskSpaceInBytes / 1024 / 1024 / 1024
        print("手机剩余储存空间为： \(free)GB")
        sessionManager.logger.option = .default
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.right.bottom.left.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        configureNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func configureNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "编辑",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(toggleEditing))
    }
    
    
    @objc func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        let button = navigationItem.rightBarButtonItem!
        button.title = tableView.isEditing ? "完成" : "编辑"
    }
    
    func setupManager() {
        
        // 设置 manager 的回调
//        sessionManager.progress { [weak self] (manager) in
////            self?.updateUI()
//            
//        }.completion { [weak self] manager in
////            self?.updateUI()
//            if manager.status == .succeeded {
//                // 下载成功
//            } else {
//                // 其他状态
//            }
//        }
    }
    
    func clearDisk(_ sender: Any) {
        sessionManager.cache.clearDiskCache()
//        updateUI()
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "\(DownloadTaskCell.self)", bundle: nil),
                           forCellReuseIdentifier: DownloadTaskCell.reuseIdentifier)
        return tableView
    }()
}

extension DownloadVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessionManager.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DownloadTaskCell.reuseIdentifier, for: indexPath) as! DownloadTaskCell
        return cell
    }
    
    // 每个 cell 中的状态更新，应该在 willDisplay 中执行
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let task = sessionManager.tasks.safeObject(at: indexPath.row),
              let cell = cell as? DownloadTaskCell
        else { return }
        
        cell.task?.progress { _ in }.success { _ in }.failure { _ in }
        
        cell.task = task
        
        cell.titleLabel.text = task.fileName
        
        cell.updateProgress(task)
        
        cell.tapClosure = { [weak self] cell in
            guard let `self` = self else { return }
            guard let task = self.sessionManager.tasks.safeObject(at: indexPath.row) else { return }
            switch task.status {
                case .waiting, .running:
                    self.sessionManager.suspend(task)
                case .suspended, .failed:
                    self.sessionManager.start(task)
                case .succeeded:
                let playerC = AVPlayerViewController()
                let player = AVPlayer(url: URL(fileURLWithPath: task.filePath))
                player.play()
                playerC.player = player
                self.present(playerC, animated: true)
                default:
                    break
            }
        }
        
        task.progress { [weak cell] task in
            cell?.updateProgress(task)
        }
        .success { [weak cell] (task) in
            cell?.updateProgress(task)
            // 下载任务成功了
            
        }
        .failure { [weak cell] task in
            cell?.updateProgress(task)
            if task.status == .suspended {
                // 下载任务暂停了
            }
            
            if task.status == .failed {
                // 下载任务失败了
            }
            if task.status == .canceled {
                // 下载任务取消了
            }
            if task.status == .removed {
                // 下载任务移除了
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let task = sessionManager.tasks.safeObject(at: indexPath.row) else { return }
            sessionManager.remove(task, completely: false) { [weak self] _ in
                self?.tableView.deleteRows(at: [indexPath], with: .automatic)
//                self?.updateUI()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        sessionManager.moveTask(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        "删除"
    }
}

//
//  DownloadTaskCell.swift
//  Example
//
//  Created by Daniels on 2018/3/16.
//  Copyright © 2018 Daniels. All rights reserved.
//

import UIKit
import Tiercel

class DownloadTaskCell: UITableViewCell {
    
    static let reuseIdentifier = "reuseIdentifier"

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var bytesLabel: UILabel!
    @IBOutlet weak var controlButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var thumbView: UIImageView!
    var tapClosure: ((DownloadTaskCell) -> Void)?
    
    @IBOutlet weak var progressView: AIDownloadProgressView!
    var task: DownloadTask?


    @IBAction func didTapButton(_ sender: Any) {
        tapClosure?(self)
    }

    func updateProgress(_ task: DownloadTask) {
        progressView.progress = Double(task.progress.completedUnitCount) / Double(task.progress.totalUnitCount)
//        bytesLabel.text = "\(task.progress.completedUnitCount.tr.convertBytesToString())/\(task.progress.totalUnitCount.tr.convertBytesToString())"
//        speedLabel.text = task.speedString
//        timeRemainingLabel.text = "剩余时间：\(task.timeRemainingString)"
//        startDateLabel.text = "开始时间：\(task.startDateString)"
//        endDateLabel.text = "结束时间：\(task.endDateString)"
        
        var image = UIImage(systemName: "play.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        switch task.status {
        case .suspended:
            statusLabel.text = "暂停"
            statusLabel.textColor = .black
            image = UIImage(systemName: "arrow.down.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        case .running:
            image = UIImage(systemName: "pause.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            statusLabel.text = "下载中"
            statusLabel.textColor = .systemBlue
        case .succeeded:
            statusLabel.text = "成功"
            statusLabel.textColor = .systemGreen
        case .failed:
            statusLabel.text = "失败"
            statusLabel.textColor = .systemRed
        case .waiting:
            image = UIImage(systemName: "clock", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            statusLabel.text = "等待中"
            statusLabel.textColor = .systemOrange
        default:
            image = controlButton.imageView?.image ?? #imageLiteral(resourceName: "suspend")
            break
        }
        controlButton.setImage(image, for: .normal)
    }

}

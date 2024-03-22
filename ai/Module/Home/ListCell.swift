//
//  ListCell.swift
//  
//
//  Created by 范东 on 2022/5/10.
//

import UIKit
import SnapKit

class ListCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bgImageView)
        bgImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(200)
        }
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.bottom.equalToSuperview().offset(-15)
            make.top.equalTo(self.bgImageView.snp.bottom).offset(15)
        }
        contentView.addSubview(durationLabel)
        durationLabel.snp.makeConstraints { make in
            make.bottom.right.equalTo(self.bgImageView).offset(-15)
            make.height.equalTo(20)
            make.width.equalTo(70)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var _model: ListModel!
    public var model : ListModel!{
        get {
            _model
        }
        set {
            _model = newValue
            bgImageView.sd_setImage(with: URL(string: newValue.thumbnailUrl))
            titleLabel.text = newValue.title
            durationLabel.text = newValue.duration
        }
    }
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    lazy var bgImageView: UIImageView = {
        let bgImageView = UIImageView(frame: .zero)
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        return bgImageView
    }()
    
    lazy var durationLabel: UILabel = {
        let durationLabel = UILabel(frame: .zero)
        durationLabel.font = .systemFont(ofSize: 13)
        durationLabel.textColor = .white
        durationLabel.backgroundColor = .darkGray.withAlphaComponent(0.5)
        durationLabel.layer.cornerRadius = 5
        durationLabel.clipsToBounds = true
        durationLabel.textAlignment = .center
        return durationLabel
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  ToDoCell.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/17/23.
//

import SnapKit
import RxSwift

class ListCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let flagImageView = UIImageView()
    private let expiredSoonLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        flagImageView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        dateLabel.text = nil
        expiredSoonLabel.isHidden = true
    }
    
    func configureWith(title: String, description: String, date: String, flaged: Bool, isExpiredSoon: Bool) {
        titleLabel.text = title
        descriptionLabel.text = description
        dateLabel.text = date
        if flaged {
            flagImageView.image = UIImage(systemName: "flag.circle")
        }
        expiredSoonLabel.isHidden = !isExpiredSoon
    }
}

private extension ListCell {
    
    func setupView() {
        
        self.do {
            $0.selectionStyle = .none
        }
        
        titleLabel.do {
            $0.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            $0.textColor = UIColor(named: "titleColor")
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.sizeToFit()
        }
        
        descriptionLabel.do {
            $0.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            $0.textColor = UIColor(named: "descColor")
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.sizeToFit()
        }
        
        dateLabel.do {
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = UIColor(named: "descColor")
            $0.textAlignment = .left
        }
        
        flagImageView.do {
            $0.tintColor = .systemRed
            $0.contentMode = .scaleAspectFill
        }
        
        expiredSoonLabel.do {
            $0.text = "Expired soon"
            $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .systemRed
            $0.textAlignment = .center
        }
    }
    
    func setupConstraints() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(flagImageView)
        contentView.addSubview(expiredSoonLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-8)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().offset(-8)
        }
        
        flagImageView.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.top.trailing.equalToSuperview().inset(8)
        }
        
        expiredSoonLabel.snp.makeConstraints {
            $0.bottom.equalTo(dateLabel)
            $0.trailing.equalTo(flagImageView)
        }
    }
}

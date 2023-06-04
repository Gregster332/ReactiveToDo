//
//  HomeCell.swift
//  DelegateMethod
//
//  Created by Greg Zenkov on 5/31/23.
//

import SnapKit

class HomeCell: UICollectionViewCell {
    
    private let mainLabel = UILabel()
    private let icon = UIImageView()
    private let countLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
    }
    
    func configure(with item: HomeSection.Item) {
        mainLabel.text = item.name
        icon.image = item.image
        countLabel.text = "\(item.count)"
    }
}

private extension HomeCell {
    
    func setupView() {
        
        contentView.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
        }
        
        mainLabel.do {
            $0.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            $0.textColor = .black
            $0.textAlignment = .left
        }
        
        icon.do {
            $0.contentMode = .scaleAspectFill
        }
        
        countLabel.do {
            $0.font = UIFont.rounded(ofSize: 23, weight: .semibold)
            $0.textColor = .systemGray3
            $0.textAlignment = .center
        }
    }
    
    func setupConstraints() {
        contentView.addSubview(mainLabel)
        contentView.addSubview(icon)
        contentView.addSubview(countLabel)
        
        mainLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(10)
        }
        
        icon.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(26)
        }
        
        countLabel.snp.makeConstraints {
            $0.trailing.equalTo(icon)
            $0.top.equalTo(icon.snp.bottom).offset(16)
        }
    }
}

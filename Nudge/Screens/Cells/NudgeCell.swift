//
//  NudgeCell.swift
//  Nudges
//
//  Created by Benny Pham on 3/25/21.
//

import UIKit

class NudgeCell: UICollectionViewCell {
    
    static let reuseID = "NudgeCell"
    let titleLabel = NudgeTitleLabel(textAlignment: .left, fontSize: 25)
    let bodyLabel = NudgeBodyLabel(textAlignment: .left)
    let dateLabel = NudgeBodyLabel(textAlignment: .left)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func set(nudge: Nudge) {
        titleLabel.text = nudge.title
        bodyLabel.text = nudge.body
    }
    
    func setDate(nudge: Nudge) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = dateFormatter.string(from: nudge.date)
    }
    
    
    private func configure() {
        addSubview(titleLabel)
        addSubview(bodyLabel)
        addSubview(dateLabel)
        
        let padding = CGFloat(20)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
//            titleLabel.heightAnchor.constraint(equalTo: titleLabel.widthAnchor),
            
        
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            bodyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            bodyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            bodyLabel.heightAnchor.constraint(equalToConstant: 20),
            
            dateLabel.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 12),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            dateLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

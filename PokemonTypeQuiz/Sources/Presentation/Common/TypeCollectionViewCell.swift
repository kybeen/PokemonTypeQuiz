//
//  TypeCollectionViewCell.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

// MARK: - 타입 버튼 컬렉션 뷰 셀
final class TypeCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "typeCollectionViewCell"
    
    let typeStackView: UIStackView = {
        let typeStackView = UIStackView()
        typeStackView.axis = .vertical
        typeStackView.distribution = .fillEqually
        return typeStackView
    }()
    let typeImageView: UIImageView = {
        let typeImageView = UIImageView()
        typeImageView.contentMode = .scaleAspectFit
        return typeImageView
    }()
    let typeNameLabel: UILabel = {
        let typeNameLabel = UILabel()
        typeNameLabel.textAlignment = .center
        return typeNameLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        setupUI()

    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupUI() {
        addSubview(typeStackView)
        typeStackView.addArrangedSubview(typeImageView)
        typeStackView.addArrangedSubview(typeNameLabel)
        
        typeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

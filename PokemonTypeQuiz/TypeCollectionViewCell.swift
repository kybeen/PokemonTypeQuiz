//
//  TypeCollectionViewCell.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

final class TypeCollectionViewCell: UICollectionViewCell {

    static let cellIdentifier = "typeCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        self.layer.cornerRadius = 15
        setupUI()

    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupUI() {

    }
}

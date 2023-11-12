//
//  MainView.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

final class MainView: UIView {

    // 도감번호
    let pokemonID: UILabel = {
        let pokemonID = UILabel()
        pokemonID.text = "도감번호: ??"
        pokemonID.textAlignment = .center
        pokemonID.textColor = .black
        return pokemonID
    }()

    // 이름
    let pokemonName: UILabel = {
        let pokemonName = UILabel()
        pokemonName.text = "불러오는중..."
        pokemonName.textAlignment = .center
        pokemonName.font = UIFont.boldSystemFont(ofSize: 30)
        return pokemonName
    }()

    // 이미지
    let pokemonImageView: UIImageView = {
        let pokemonImageView = UIImageView()
        pokemonImageView.contentMode = .scaleAspectFill
        return pokemonImageView
    }()

    // 타입 선택 버튼 컬렉션 뷰
    let typeCollectionView: UICollectionView = {
        let typeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        typeCollectionView.backgroundColor = .clear
        return typeCollectionView
    }()

    // 정답 제출 버튼
    let submitButton: UIButton = {
        let submitButton = UIButton()
        
        var titleAttr = AttributedString("정답 제출하기")
        titleAttr.font = UIFont.boldSystemFont(ofSize: 24)
        titleAttr.foregroundColor = .white
        var config = UIButton.Configuration.filled()
        config.attributedTitle = titleAttr
        config.background.cornerRadius = 15
        config.baseBackgroundColor = .systemBlue
//        config.contentInsets = NSDirectionalEdgeInsets(
//            top: 5,
//            leading: 10,
//            bottom: 5,
//            trailing: 10
//        )
        submitButton.configuration = config
        return submitButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        addSubview(pokemonID)
        pokemonID.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalToSuperview()
        }
        
        addSubview(pokemonName)
        pokemonName.snp.makeConstraints { make in
            make.top.equalTo(pokemonID.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        addSubview(pokemonImageView)
        pokemonImageView.snp.makeConstraints { make in
            make.top.equalTo(pokemonName.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
            make.height.equalTo(150)
        }
        
        addSubview(typeCollectionView)
        typeCollectionView.snp.makeConstraints { make in
            make.top.equalTo(pokemonImageView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(100)
        }
        
        addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(typeCollectionView.snp.bottom).offset(20)
            make.height.equalTo(60)
        }
    }
}

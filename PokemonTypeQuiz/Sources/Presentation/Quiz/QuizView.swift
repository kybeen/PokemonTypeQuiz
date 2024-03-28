//
//  QuizView.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

final class QuizView: UIView {

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
        pokemonImageView.contentMode = .scaleAspectFit
        return pokemonImageView
    }()

    // 포켓몬 변경 버튼
    let changeButton: UIButton = {
        let reloadButton = UIButton()
        // SF Symbol 설정
        let symbolFont = UIFont.boldSystemFont(ofSize: 20)
        let symbolConfiguration = UIImage.SymbolConfiguration(font: symbolFont)
        let symbolImage = UIImage(systemName: "arrow.counterclockwise", withConfiguration: symbolConfiguration)
        var config = UIButton.Configuration.plain()
        config.image = symbolImage
        config.imagePlacement = .bottom
        reloadButton.configuration = config
        return reloadButton
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

        addSubview(changeButton)
        changeButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(30)
            make.centerY.equalTo(pokemonImageView)
        }
    }
}

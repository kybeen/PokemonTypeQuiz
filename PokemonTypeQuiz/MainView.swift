//
//  MainView.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

final class MainView: UIView {

    let pokemonID: UILabel = {
        let pokemonID = UILabel()
        pokemonID.text = "도감번호: ??"
        pokemonID.textAlignment = .center
        pokemonID.textColor = .black
//        pokemonID.backgroundColor = .gray
        return pokemonID
    }()
    let pokemonName: UILabel = {
        let pokemonName = UILabel()
        pokemonName.text = "불러오는중..."
        pokemonName.textAlignment = .center
        pokemonName.font = UIFont.boldSystemFont(ofSize: 30)
//        pokemonName.backgroundColor = .orange
        return pokemonName
    }()
    let pokemonImageView: UIImageView = {
        let pokemonImageView = UIImageView()
        pokemonImageView.contentMode = .scaleAspectFill
//        pokemonImageView.backgroundColor = .blue
        return pokemonImageView
    }()
    let typeCollectionView: UICollectionView = {
        let typeCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
//        typeCollectionView.backgroundColor = .red
        typeCollectionView.backgroundColor = .clear
        return typeCollectionView
    }()
    let submitButton: UIButton = {
        let submitButton = UIButton()
        submitButton.setTitle("정답 제출", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 15
        submitButton.layer.masksToBounds = true
        
        submitButton.setBackgroundImage(UIImage(color: .blue), for: .highlighted)
        
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

extension UIImage {
    convenience init(color: UIColor) {
        let rect = CGRect(origin: .zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }
}


// MARK: - Preview canvas 세팅
import SwiftUI

struct MainViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MainViewController
    func makeUIViewController(context: Context) -> MainViewController {
        return MainViewController()
    }
    func updateUIViewController(_ uiViewController: MainViewController, context: Context) {
    }
}
@available(iOS 13.0.0, *)
struct MainViewPreview: PreviewProvider {
    static var previews: some View {
        MainViewControllerRepresentable()
    }
}

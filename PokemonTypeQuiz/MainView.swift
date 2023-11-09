//
//  MainView.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

final class MainView: UIView {

    private let pokemonID: UILabel = {
        let pokemonID = UILabel()
        pokemonID.text = "도감번호: ??"
        pokemonID.textAlignment = .center
        return pokemonID
    }()
    private let pokemonName: UILabel = {
        let pokemonName = UILabel()
        pokemonName.text = "불러오는중..."
        pokemonName.textAlignment = .center
        pokemonName.font = UIFont.boldSystemFont(ofSize: 30)
        return pokemonName
    }()
    private let pokemonImageView: UIImageView = {
        let pokemonImageView = UIImageView()
        let imageURL: URL! = URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png")
        let imageData = try! Data(contentsOf: imageURL)
        pokemonImageView.image = UIImage(data: imageData)
        pokemonImageView.contentMode = .scaleAspectFill
        pokemonImageView.backgroundColor = .gray
        return pokemonImageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupUI() {
        addSubview(pokemonID)
        pokemonID.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.centerX.equalToSuperview()
        }
        
        addSubview(pokemonName)
        pokemonName.snp.makeConstraints { make in
            make.top.equalTo(pokemonID.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        addSubview(pokemonImageView)
        pokemonImageView.snp.makeConstraints { make in
            make.top.equalTo(pokemonName.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
            make.height.equalTo(200)
        }
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

//
//  MainViewController.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

import SnapKit

class MainViewController: UIViewController {

    private let mainView = MainView()
//    var randomPokemon: Pokemon? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        mainView.typeCollectionView.register(
            TypeCollectionViewCell.self,
            forCellWithReuseIdentifier: TypeCollectionViewCell.cellIdentifier
        )
        mainView.typeCollectionView.delegate = self
        mainView.typeCollectionView.dataSource = self
        
        loadRandomPokemon(id: randomIDGenerator())
    }

    private func loadRandomPokemon(id: Int) {
        let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
        let apiURI: URL! = URL(string: url)
        
        let apiData = try! Data(contentsOf: apiURI)
        
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apiData, options: []) as! NSDictionary
            
            // 도감번호
            let idValue = apiDictionary["id"] as! Int
            print("idValue: \(idValue)")

            // 영문이름
            let nameValue = apiDictionary["name"] as! String
            print("nameValue: \(nameValue)")

            // 이미지 URL
            let sprites = apiDictionary["sprites"] as! NSDictionary
            let imageURLValue = sprites["front_default"] as! String
            print("imageURLValue: \(imageURLValue)")

            // 타입1
            let typesArr = apiDictionary["types"] as! NSArray
            let type1Value: String = {
                let dict = typesArr[0] as! NSDictionary
                let dict2 = dict["type"] as! NSDictionary
                let type1 = dict2["name"] as! String
                return type1
            }()
            print("type1Value: \(type1Value)")
            
            // 타입2
            var type2Value: String?
            if typesArr.count > 1 {
                let dict = typesArr[1] as! NSDictionary
                let dict2 = dict["type"] as! NSDictionary
                let type2 = dict2["name"] as! String
                type2Value = type2
            }
            print("type2Value: \(type2Value)")

            mainView.pokemonID.text = "도감번호: \(idValue)"
            mainView.pokemonName.text = nameValue
            
            let imageURL: URL! = URL(string: imageURLValue)
            let imageData = try! Data(contentsOf: imageURL)
            mainView.pokemonImageView.image = UIImage(data: imageData)
        } catch {
            print("오류")
        }
    }

    private func randomIDGenerator() -> Int {
        let randomNumber = Int(arc4random_uniform(151)) + 1
        return randomNumber
    }
}

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return englishType.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeCollectionViewCell.cellIdentifier, for: indexPath) as? TypeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.typeImageView.image = UIImage(named: englishType[indexPath.row])
        cell.typeNameLabel.text = koreanType[indexPath.row]
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 80)
    }
}

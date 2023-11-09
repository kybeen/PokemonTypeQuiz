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
    var type1Answer: String?
    var type2Answer: String?
    
    var userTypeAnswer = [Int]()

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
        
        mainView.submitButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)
        
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
            
            type1Answer = type1Value
            type2Answer = type2Value
        } catch {
            print("오류")
        }
    }

    private func randomIDGenerator() -> Int {
        let randomNumber = Int(arc4random_uniform(151)) + 1
        return randomNumber
    }
    
    @objc private func submitAnswer() {
        if userTypeAnswer.count == 0 {
            noValueAlert()
        } else {
            let answerArr = convertIndexToTypeString(userTypeAnswer: userTypeAnswer)
            if let type2Answer = type2Answer { // 포켓몬의 타입이 2개일 때
                // 둘 다 정답 배열에 있으면 정답
                if answerArr.contains(type1Answer!) && answerArr.contains(type2Answer) {
                    correctAlert(type1: type1Answer!, type2: type2Answer)
                    userTypeAnswer = []
                    reloadValues(collectionView: mainView.typeCollectionView)
                    loadRandomPokemon(id: randomIDGenerator())
                } else {
                    failAlert()
                }
            } else { // 포켓몬의 타입이 1개일 때
                if answerArr.contains(type1Answer!) {
                    correctAlert(type1: type1Answer!, type2: type2Answer)
                    userTypeAnswer = []
                    reloadValues(collectionView: mainView.typeCollectionView)
                    loadRandomPokemon(id: randomIDGenerator())
                } else {
                    failAlert()
                }
            }
        }
        print(userTypeAnswer)
    }
    
    func convertIndexToTypeString(userTypeAnswer: [Int]) -> [String] {
        var typeStringArr = [String]()
        for idx in userTypeAnswer {
            let value = englishType[idx]
            typeStringArr.append(value)
        }
        return typeStringArr
    }
    private func noValueAlert() {
        let alert = UIAlertController(title: "선택한 값 없음", message: "1개 혹은 2개의 타입을 선택해주세요", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    private func correctAlert(type1: String, type2: String?) {
        var alert: UIAlertController
        if let type2 = type2 {
            alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(type1), \(type2)", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(type1)", preferredStyle: .alert)
        }
//        let alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(type1), \(type2)", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    private func failAlert() {
        let alert = UIAlertController(title: "틀렸습니다...", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource {

    // 컬렉션 뷰 아이템 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return englishType.count
    }
    
    // 컬렉션 뷰 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeCollectionViewCell.cellIdentifier, for: indexPath) as? TypeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.typeImageView.image = UIImage(named: englishType[indexPath.row])
        cell.typeNameLabel.text = koreanType[indexPath.row]
        return cell
    }
    
    // 셀 선택 시 동작
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("누른 자리: \(indexPath.row)")
        // 선택되어있는 값이면 userTypeAnswer에서 제거
        if let index = userTypeAnswer.firstIndex(of: indexPath.row) {
            userTypeAnswer.remove(at: index)
            print("선택 해제됨!! \(userTypeAnswer)")
        } else {
            // 선택되어 있지 않은 값이고, userTypeAnswer의 값이 2개 미만일 때 userTypeAnswer에 추가
            if userTypeAnswer.count < 2 {
                userTypeAnswer.append(indexPath.row)
                print("선택됨!! \(userTypeAnswer)")
            }
        }
        reloadValues(collectionView: collectionView)
    }
    
    // 셀 선택 처리 메서드
    func reloadValues(collectionView: UICollectionView) {
        // 0~17까지 인덱스 중 userTypeAnswer에 있는 값이면 셀에 선택 효과 적용
        for idx in 0..<18 {
            guard let cell = collectionView.cellForItem(at: IndexPath(row: idx, section: 0)) as? TypeCollectionViewCell else {
                return
            }
            if userTypeAnswer.contains(idx) {
//                cell.layer.borderWidth = 5
                cell.backgroundColor = .gray.withAlphaComponent(0.5)
            } else {
//                cell.layer.borderWidth = 1
                cell.backgroundColor = .clear
            }
        }
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    // 기준 행 또는 열 사이에 들어가는 아이템 사이의 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        6
    }
    // 컬렉션 뷰의 사이즈
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 80)
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

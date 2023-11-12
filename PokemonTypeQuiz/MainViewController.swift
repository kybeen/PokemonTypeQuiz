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
    var pokemonNameDictionary = [String:String]()
    var type1Answer: String? // 포켓몬의 타입1
    var type2Answer: String? // 포켓몬의 타입2
    
    var userTypeAnswer = [Int]() // 유저가 선택한 타입(인덱스) 배열

    override func viewDidLoad() {
        super.viewDidLoad()
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

        loadPokemonNameCSV()
        loadRandomPokemon(id: randomIDGenerator())
    }

    // 랜덤 포켓몬 불러오기
    private func loadRandomPokemon(id: Int) {
        let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
        let apiURI: URL! = URL(string: url)
        
        let apiTask = URLSession.shared.dataTask(with: apiURI) { (data, response, error) in
            if let error = error {
                print("error: \(error)")
            } else if let data = data {
                DispatchQueue.main.async {
                    do {
                        let apiDictionary = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        
                        // 도감번호
                        let idValue = apiDictionary["id"] as! Int
                        // 영문이름
                        let nameValue = apiDictionary["name"] as! String
                        // 이미지 URL
                        let sprites = apiDictionary["sprites"] as! NSDictionary
                        let imageURLValue = sprites["front_default"] as! String
                        // 타입1
                        let typesArr = apiDictionary["types"] as! NSArray
                        let type1Value: String = {
                            let dict = typesArr[0] as! NSDictionary
                            let dict2 = dict["type"] as! NSDictionary
                            let type1 = dict2["name"] as! String
                            return type1
                        }()
                        // 타입2
                        var type2Value: String?
                        if typesArr.count > 1 {
                            let dict = typesArr[1] as! NSDictionary
                            let dict2 = dict["type"] as! NSDictionary
                            let type2 = dict2["name"] as! String
                            type2Value = type2
                        }

                        self.mainView.pokemonID.text = "도감번호: \(idValue)"
                        self.mainView.pokemonName.text = self.pokemonNameDictionary[nameValue.capitalized]
                        if let value = enToKoNameDict[nameValue] {
                            self.mainView.pokemonName.text = value
                        }
                        self.type1Answer = type1Value
                        self.type2Answer = type2Value
                        
                        let imageURL: URL! = URL(string: imageURLValue)
                        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                            if let error = error {
                                print("error: \(error)")
                            } else if let data = data {
                                DispatchQueue.main.async {
                                    self.mainView.pokemonImageView.image = UIImage(data: data)
                                }
                            }
                        }
                        task.resume()
                    } catch {
                        print("오류")
                    }
                }
            }
        }
        apiTask.resume()
    }
    // 도감 번호 랜덤 추출
    private func randomIDGenerator() -> Int {
        let randomNumber = Int(arc4random_uniform(151)) + 1
        return randomNumber
    }
}

// MARK: - CSV 데이터 처리 관련 메서드
extension MainViewController {

    // MARK: - 포켓몬 이름 데이터 불러오기
    private func loadPokemonNameCSV() {
        print("loadPokemonNameCSV()...")
        let path = Bundle.main.path(forResource: "pokemonNames", ofType: "csv")!
        print(path)

        parseCSV(url: URL(fileURLWithPath: path))
    }
    
    // MARK: - CSV 파일을 파싱하는 메서드
    private func parseCSV(url: URL) {
        print("parseCSV()...")
        do {
            let data = try Data(contentsOf: url)
            if let dataEncoded = String(data: data, encoding: .utf8) {
                var lines = dataEncoded.components(separatedBy: "\n")
                lines.removeFirst()
                
                var koName = ""
                var enName = ""
                for line in lines {
                    let columns = line.components(separatedBy: ",")
                    guard columns.count == 4 else {
                        break
                    }
                    if columns[1] == "3" {
                        koName = columns[2]
                    } else if columns[1] == "9" {
                        enName = columns[2]
                        pokemonNameDictionary[enName] = koName
                    }
                }
                print(pokemonNameDictionary)
            }
        } catch {
            print("CSV 파일을 읽는 도중 에러가 발생했습니다!!")
        }
    }
}

// MARK: - 정답 제출 로직 관련 메서드
extension MainViewController {

    // 정답 제출 버튼 클릭 시 호출
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
                if answerArr.count == 2 { // 타입을 2개 골랐으면 틀림
                    failAlert()
                } else {
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
        }
        print(userTypeAnswer)
    }

    // 타입 인덱스가 들어 있는 정답 배열을 타입 String 값이 들어 있는 배열로 바꿔서 반환
    func convertIndexToTypeString(userTypeAnswer: [Int]) -> [String] {
        var typeStringArr = [String]()
        for idx in userTypeAnswer {
            let value = englishType[idx]
            typeStringArr.append(value)
        }
        return typeStringArr
    }

    // 선택한 타입이 없을 때
    private func noValueAlert() {
        let alert = UIAlertController(title: "타입 선택하지 않음", message: "1개 혹은 2개의 타입을 선택해주세요", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    // 정답일 때
    private func correctAlert(type1: String, type2: String?) {
        var alert: UIAlertController
        if let type2 = type2 { // 타입이 2개일 때
            alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(enToKoTypeDict[type1]!), \(enToKoTypeDict[type2]!)", preferredStyle: .alert)
        } else { // 타입이 1개일 때
            alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(enToKoTypeDict[type1]!)", preferredStyle: .alert)
        }
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    // 틀렸을 때
    private func failAlert() {
        let alert = UIAlertController(title: "틀렸습니다...", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDataSource 델리게이트 구현
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
                cell.layer.borderWidth = 3
                cell.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                cell.backgroundColor = .gray.withAlphaComponent(0.5)
                cell.typeNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
            } else {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.black.cgColor
                cell.backgroundColor = .clear
                cell.typeNameLabel.font = UIFont.systemFont(ofSize: 16)
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout 델리게이트 구현
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

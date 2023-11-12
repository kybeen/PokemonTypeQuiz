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
    var pokemonNameDictionary = [String:String]() // 영어:한글 쌍의 포켓몬 이름 딕셔너리
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

        // 번역된 포켓몬 이름 CSV 데이터 불러오기
        loadPokemonNameCSV()
        // 1~151 중 랜덤한 도감번호의 포켓몬 불러오기
        loadRandomPokemon(id: randomIDGenerator())
    }

    // MARK: - 도감 번호 랜덤 추출
    private func randomIDGenerator() -> Int {
        // 1~151 번 중에서 랜덤
        let randomNumber = Int.random(in: 0...151)
        return randomNumber
    }
}

// MARK: - 네트워크 통신 관련
extension MainViewController {

    // 에러 타입
    enum NetworkError: Error {
        case invalidURL
        case invalidResponse
    }
    enum ImageError: Error {
        case invalidData
    }

    // MARK: - 랜덤 포켓몬 불러오기
    private func loadRandomPokemon(id: Int) {
        // id 도감번호에 해당하는 포켓몬을 호출하기 위한 엔드포인트
        let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
        guard let apiURI = URL(string: url) else { return }

        let session = URLSession(configuration: .default)
        session.dataTask(with: apiURI) { data, response, error in
            if let error = error {
                print("error: \(error)")
            }
            guard let data = data else {
                return
            }

            // 응답으로 받은 객체를 PokemonData 타입으로 디코딩해서 처리
            do {
                let pokemonData = try JSONDecoder().decode(PokemonData.self, from: data)
                DispatchQueue.main.async {

                    // 도감 번호 처리
                    self.mainView.pokemonID.text = "도감번호: \(pokemonData.id)"

                    // 이름 처리
                    // TODO: - 마임맨(mr-mime) 👉 예외처리 필요 (-가 있어서 딕셔너리 키값으로 검색이 안됨)
                    let koreanName = self.pokemonNameDictionary[pokemonData.name.capitalized] // 한글 이름 매핑
                    self.mainView.pokemonName.text = koreanName

                    // 이미지 처리
                    Task {
                        self.mainView.pokemonImageView.image = try await self.fetchPokemonImage(for: pokemonData.sprites.frontDefault!)
                    }
                    
                    // 타입1 처리
                    if let type1 = pokemonData.types[0] {
                        self.type1Answer = type1.type.name
                    }
                    // 타입2 처리
                    if pokemonData.types.count > 1 {
                        if let type2 = pokemonData.types[1] {
                            self.type2Answer = type2.type.name
                        }
                    }
                }
            } catch {
                print("에러")
            }
        }.resume()
    }

    // MARK: - 이미지 로드 메서드 (async 사용)
    private func fetchPokemonImage(for id: String) async throws -> UIImage {
        let request = URLRequest(url: URL(string: id)!)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let image = UIImage(data: data)
        guard let image = image else{
            throw ImageError.invalidData
        }
        return image
    }
}

// MARK: - CSV 데이터 처리 관련 메서드
extension MainViewController {

    // 번역된 포켓몬 이름 CSV 데이터를 불러오는 메서드
    private func loadPokemonNameCSV() {
        print("loadPokemonNameCSV()...")
        let path = Bundle.main.path(forResource: "pokemonNames", ofType: "csv")!
        print(path)

        parseCSV(url: URL(fileURLWithPath: path))
    }
    
    // CSV 파일을 파싱하는 메서드
    private func parseCSV(url: URL) {
        print("parseCSV()...")
        let data = try? Data(contentsOf: url) /// Data(contentsOf:) 는 동기적으로 작동함 👉 메인 스레드를 잡아먹기 때문에 네트워크 통신에서는 사용하지 맙시다
        guard let data = data else {
            print("CSV 파일을 불러오지 못함")
            return
        }
        print("CSV 파일을 불러왔습니다!!")
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
//            print(pokemonNameDictionary)
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
        // 정답 초기화
        type1Answer = nil
        type2Answer = nil
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
        return enToKoTypeDict.count
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

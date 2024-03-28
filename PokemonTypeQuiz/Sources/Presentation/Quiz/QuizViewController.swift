//
//  QuizViewController.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

import SnapKit

class QuizViewController: UIViewController {

    private let quizView = QuizView()
    var pokemonNameDictionary = [String:String]() // 영어:한글 쌍의 포켓몬 이름 딕셔너리
    var type1Answer: PokemonType? // 포켓몬의 타입1
    var type2Answer: PokemonType? // 포켓몬의 타입2
    
    var userTypeAnswer = [Int]() // 유저가 선택한 타입(인덱스) 배열

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(quizView)
        quizView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        quizView.typeCollectionView.register(
            TypeCollectionViewCell.self,
            forCellWithReuseIdentifier: TypeCollectionViewCell.cellIdentifier
        )
        quizView.typeCollectionView.delegate = self
        quizView.typeCollectionView.dataSource = self
        
        quizView.changeButton.addTarget(self, action: #selector(changePokemon), for: .touchUpInside)
        quizView.submitButton.addTarget(self, action: #selector(submitAnswer), for: .touchUpInside)

        // 번역된 포켓몬 이름 CSV 데이터 불러오기
        loadPokemonNameCSV()
        // 1~151 중 랜덤한 도감번호의 포켓몬 불러오기
        loadRandomPokemon(id: Int.randomID)
    }
    
    deinit {
        print("QuizViewController deinitialized 🚮")
    }
}

// MARK: - 네트워크 통신 관련
extension QuizViewController {

    // MARK: - 포켓몬 변경 버튼 클릭 시 호출
    @objc func changePokemon() {
        quizView.pokemonID.text = "도감번호: "
        quizView.pokemonName.text = "불러오는 중..."
        quizView.pokemonImageView.image = nil
        // 정답 내용 초기화
        type1Answer = nil
        type2Answer = nil
        userTypeAnswer = []
        reloadValues(collectionView: quizView.typeCollectionView)
        loadRandomPokemon(id: Int.randomID)
    }
}

// MARK: - CSV 데이터 처리 관련 메서드
extension QuizViewController {

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
extension QuizViewController {

    // 정답 제출 버튼 클릭 시 호출
    @objc private func submitAnswer() {
        if userTypeAnswer.count == 0 {
            noValueAlert()
        } else {
            let answerArr = convertIndexToPokemonType(userTypeAnswer: userTypeAnswer)
            if let type1Answer = type1Answer,
               let type2Answer = type2Answer { // 포켓몬의 타입이 2개일 때
                // 둘 다 정답 배열에 있으면 정답
                if answerArr.contains(type1Answer) && answerArr.contains(type2Answer) {
                    correctAlert(type1: type1Answer, type2: type2Answer)
                } else {
                    failAlert()
                }
            } else { // 포켓몬의 타입이 1개일 때
                if !(type1Answer == nil && type2Answer == nil) { // 정답 값이 둘 다 nil인 경우 예외처리
                    if answerArr.count == 2 { // 타입을 2개 골랐으면 틀림
                        failAlert()
                    } else {
                        if answerArr.contains(type1Answer!) {
                            correctAlert(type1: type1Answer!, type2: type2Answer)
                        } else {
                            failAlert()
                        }
                    }
                }
            }
        }
        print(userTypeAnswer)
    }

    // 타입 인덱스가 들어 있는 정답 배열을 PokemonType 값이 들어 있는 배열로 바꿔서 반환
    func convertIndexToPokemonType(userTypeAnswer: [Int]) -> [PokemonType] {
        var pokemonTypeArr = [PokemonType]()
        for idx in userTypeAnswer {
            let value = PokemonType.allCases[idx]
            pokemonTypeArr.append(value)
        }
        return pokemonTypeArr
    }

    // 선택한 타입이 없을 때
    private func noValueAlert() {
        let alert = UIAlertController(title: "타입 선택하지 않음", message: "1개 혹은 2개의 타입을 선택해주세요", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    // 정답일 때
    private func correctAlert(type1: PokemonType, type2: PokemonType?) {
        var alert: UIAlertController
        if let type2 = type2 { // 타입이 2개일 때
            let koType1 = type1.koType
            let koType2 = type2.koType
            alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(koType1), \(koType2)", preferredStyle: .alert)
        } else { // 타입이 1개일 때
            let koType1 = type1.koType
            alert = UIAlertController(title: "정답입니다!!!", message: "타입: \(koType1)", preferredStyle: .alert)
        }
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
        // 포켓몬 변경
        changePokemon()
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
extension QuizViewController: UICollectionViewDataSource {

    // 컬렉션 뷰 아이템 개수 설정
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PokemonType.allCases.count
    }
    
    // 컬렉션 뷰 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeCollectionViewCell.cellIdentifier, for: indexPath) as? TypeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.typeImageView.image = UIImage(named: PokemonType.allCases[indexPath.row].rawValue)
        cell.typeNameLabel.text = PokemonType.allCases[indexPath.row].koType
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
extension QuizViewController: UICollectionViewDelegateFlowLayout {
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

struct QuizViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = QuizViewController
    func makeUIViewController(context: Context) -> QuizViewController {
        return QuizViewController()
    }
    func updateUIViewController(_ uiViewController: QuizViewController, context: Context) {
    }
}
@available(iOS 13.0.0, *)
struct MainViewPreview: PreviewProvider {
    static var previews: some View {
        QuizViewControllerRepresentable()
    }
}

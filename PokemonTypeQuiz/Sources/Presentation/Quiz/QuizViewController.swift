//
//  QuizViewController.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

class QuizViewController: UIViewController, BaseViewController {

    private let quizView = QuizView()
    // TODO: - 의존성 주입 방식으로 수정하기
    private let quizViewModel = QuizViewModel()
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        quizViewModel.pokemonInfoObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pokemonInfo in
                // 도감 번호 처리
                self?.quizView.pokemonID.text = "도감번호: \(pokemonInfo.id)"
                // 이름 처리
                // TODO: - 마임맨(mr-mime) 👉 예외처리 필요 (-가 있어서 딕셔너리 키값으로 검색이 안됨)
                self?.quizView.pokemonName.text = pokemonInfo.koName
                // 이미지 처리
                Task {
                    if let imageURL = pokemonInfo.imageURL {
                        self?.quizView.pokemonImageView.image = try await self?.quizViewModel.fetchPokemonImage(for: imageURL)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        quizViewModel.loadRandomPokemon()
    }
    
    func setupView() {
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
    }
    
    deinit {
        print("QuizViewController deinitialized 🚮")
    }
}

// MARK: - 네트워크 통신 관련
extension QuizViewController {

    // MARK: - 포켓몬 변경 버튼 클릭 시 호출
    @objc func changePokemon() {
        quizView.pokemonID.text = "도감번호: -"
        quizView.pokemonName.text = "불러오는 중..."
        quizView.pokemonImageView.image = UIImage(systemName: "questionmark")
//        // 정답 내용 초기화
//        type1Answer = nil
//        type2Answer = nil
        quizViewModel.userTypeAnswer = []
        reloadValues(collectionView: quizView.typeCollectionView)
        quizViewModel.loadRandomPokemon()
    }
}

// MARK: - 정답 제출 로직 관련 메서드
extension QuizViewController {

    // 정답 제출 버튼 클릭 시 호출
    @objc private func submitAnswer() {
        switch quizViewModel.checkAnswer() {
        case .correct(type1: let type1, type2: let type2):
            correctAlert(type1: type1, type2: type2)
        case .noValue:
            noValueAlert()
        case .fail:
            failAlert()
        }
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
        if let index = quizViewModel.userTypeAnswer.firstIndex(of: indexPath.row) {
            quizViewModel.userTypeAnswer.remove(at: index)
            print("선택 해제됨!! \(quizViewModel.userTypeAnswer)")
        } else {
            // 선택되어 있지 않은 값이고, userTypeAnswer의 값이 2개 미만일 때 userTypeAnswer에 추가
            if quizViewModel.userTypeAnswer.count < 2 {
                quizViewModel.userTypeAnswer.append(indexPath.row)
                print("선택됨!! \(quizViewModel.userTypeAnswer)")
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
            if quizViewModel.userTypeAnswer.contains(idx) {
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

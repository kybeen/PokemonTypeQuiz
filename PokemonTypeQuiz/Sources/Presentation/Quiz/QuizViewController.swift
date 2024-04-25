//
//  QuizViewController.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

import RxSwift

class QuizViewController: UIViewController, BaseViewController {
    
    private let quizView = QuizView()
    private let quizViewModel: QuizViewModel
    
    var disposeBag = DisposeBag()
    
    init(_ quizViewModel: QuizViewModel) {
        self.quizViewModel = quizViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bind()
        bindCollectionView()
        quizViewModel.viewDidLoadEvent.accept(()) // 최초 1회
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
    }
    
    func bind() {
        quizViewModel.pokemonID
            .asDriver(onErrorJustReturn: "도감번호를 불러오지 못했습니다.")
            .drive(quizView.pokemonID.rx.text)
            .disposed(by: disposeBag)
        
        quizViewModel.pokemonName
            .asDriver(onErrorJustReturn: "이름을 불러오지 못했습니다.")
            .drive(quizView.pokemonName.rx.text)
            .disposed(by: disposeBag)
        
        quizViewModel.pokemonImage
            .asDriver(onErrorJustReturn: nil)
            .drive(quizView.pokemonImageView.rx.image)
            .disposed(by: disposeBag)
        
        quizView.reloadButton.rx.tap
            .bind(to: quizViewModel.reloadButtonTap)
            .disposed(by: disposeBag)
        
        quizView.submitButton.rx.tap
            .bind(to: quizViewModel.submitButtonTap)
            .disposed(by: disposeBag)
        
        quizViewModel.answerStatus
            .subscribe(onNext: { [weak self] answerStatus in
                switch answerStatus {
                case .correct(type1: let type1, type2: let type2):
                    self?.correctAlert(type1: type1, type2: type2)
                case .noValue:
                    self?.noValueAlert()
                case .fail:
                    self?.failAlert()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindCollectionView() {
        //TODO: - 2중 구독 수정하기 ex) userAnswer를 [(PokemonType, isSelected: Bool)] 같은 식으로?
        // 셀 구성
        let typesObservable = Observable.of(PokemonType.allCases)
        typesObservable
            .bind(to: quizView.typeCollectionView.rx.items(cellIdentifier: TypeCollectionViewCell.cellIdentifier, cellType: TypeCollectionViewCell.self)) { (index, color, cell) in
                cell.typeImageView.image = UIImage(named: PokemonType.allCases[index].rawValue)
                cell.typeNameLabel.text = PokemonType.allCases[index].koType
                
                self.quizViewModel.userAnswer
                    .map { $0.contains(index) }
                    .subscribe(onNext: { isSelected in
                        if isSelected {
                            cell.layer.borderWidth = 3
                            cell.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
                            cell.backgroundColor = .gray.withAlphaComponent(0.5)
                            cell.typeNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
                        } else {
                            cell.layer.borderWidth = 1
                            cell.layer.borderColor = UIColor.black.cgColor
                            cell.backgroundColor = .clear
                            cell.typeNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        
        // 셀 선택 시 동작
        quizView.typeCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                print("누른 자리: \(indexPath.row)")
                // 선택되어있는 값이면 userTypeAnswer에서 제거
                self?.quizViewModel.typeCellTap.accept((indexPath.row))
            })
            .disposed(by: disposeBag)
        
        quizView.typeCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}

extension QuizViewController {
    
    // 선택한 타입이 없을 때 알럿
    private func noValueAlert() {
        let alert = UIAlertController(title: "타입 선택하지 않음", message: "1개 혹은 2개의 타입을 선택해주세요", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }

    // 정답일 때 알럿
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
        quizViewModel.reloadButtonTap.accept(())
    }

    // 틀렸을 때 알럿
    private func failAlert() {
        let alert = UIAlertController(title: "틀렸습니다...", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
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

#Preview {
    QuizViewController(QuizViewModel(RandomPokemonUseCase(PokemonRepository()), AnswerUseCase()))
}

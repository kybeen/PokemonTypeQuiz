//
//  QuizViewModel.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/28/24.
//

import Foundation
import UIKit

import RxSwift
import RxCocoa
import RxRelay

protocol QuizViewModelType {
    // input
    var viewDidLoadEvent: PublishRelay<Void> { get }
    var reloadButtonTap: PublishRelay<Void> { get }
    var submitButtonTap: PublishRelay<Void> { get }
    var typeCellTap: PublishRelay<Int> { get }
    
    // output
    var pokemonID: BehaviorRelay<String> { get }
    var pokemonName: BehaviorRelay<String> { get }
    var pokemonImage: BehaviorRelay<UIImage?> { get }
    var pokemonType1: BehaviorRelay<PokemonType?> { get }
    var pokemonType2: BehaviorRelay<PokemonType?> { get }
    var userAnswer: BehaviorRelay<Set<Int>> { get }
    var answerStatus: PublishRelay<AnswerStatus> { get }
}

final class QuizViewModel: QuizViewModelType {
    
    // input
    let viewDidLoadEvent = PublishRelay<Void>() // viewDidLoad 이벤트
    let reloadButtonTap = PublishRelay<Void>() // 다시 불러오기 버튼 탭
    let submitButtonTap = PublishRelay<Void>() // 정답 제출 버튼 탭
    let typeCellTap = PublishRelay<Int>() // 타입 셀 선택 이벤트
    
    // output
    let pokemonID = BehaviorRelay(value: "도감번호 : -")
    let pokemonName = BehaviorRelay(value: "none")
    let pokemonImage = BehaviorRelay<UIImage?>(value: nil)
    let pokemonType1 = BehaviorRelay<PokemonType?>(value: nil)
    let pokemonType2 = BehaviorRelay<PokemonType?>(value: nil)
    let userAnswer = BehaviorRelay(value: Set<Int>())
    let answerStatus = PublishRelay<AnswerStatus>()
    
    private let randomPokemonUseCase: RandomPokemonUseCase
    private let answerUseCase: AnswerUseCase
    
    private let disposeBag = DisposeBag()
    
    init(_ randomPokemonUseCase: RandomPokemonUseCase,
         _ answerUseCase: AnswerUseCase
    ) {
        self.randomPokemonUseCase = randomPokemonUseCase
        self.answerUseCase = answerUseCase
        
        configureInput()
        createOutput()
    }
    
    private func configureInput() {
        viewDidLoadEvent
            .subscribe(onNext: { [weak self] in
                self?.randomPokemonUseCase.loadRandomPokemon()
            })
            .disposed(by: disposeBag)
        
        reloadButtonTap
            .subscribe(onNext: { [weak self] in
                self?.randomPokemonUseCase.loadRandomPokemon()
                self?.answerUseCase.resetUserAnswer()
            })
            .disposed(by: disposeBag)
        
        submitButtonTap
            .subscribe(onNext: { [weak self] in
                self?.answerUseCase.checkAnswer(type1: self?.pokemonType1.value, type2: self?.pokemonType2.value)
            })
            .disposed(by: disposeBag)
        
        typeCellTap
            .subscribe(onNext: { [weak self] selectedCellIdx in
                self?.answerUseCase.selectType(selectedCellIdx)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func createOutput() {
        randomPokemonUseCase.pokemonInfo
            .map { "도감번호 : \($0.id)" }
            .bind(to: pokemonID)
            .disposed(by: disposeBag)
        
        randomPokemonUseCase.pokemonInfo
            .map { $0.koName }
            .bind(to: pokemonName)
            .disposed(by: disposeBag)
        
        randomPokemonUseCase.pokemonImageData
            .map { UIImage(data: $0) }
            .bind(to: pokemonImage)
            .disposed(by: disposeBag)
        
        randomPokemonUseCase.pokemonInfo
            .map { $0.type1 }
            .bind(to: pokemonType1)
            .disposed(by: disposeBag)
        
        randomPokemonUseCase.pokemonInfo
            .map { $0.type2 }
            .bind(to: pokemonType2)
            .disposed(by: disposeBag)
        
        answerUseCase.userAnswer
            .bind(to: userAnswer)
            .disposed(by: disposeBag)
        
        answerUseCase.answerStatus
            .bind(to: answerStatus)
            .disposed(by: disposeBag)
    }
}

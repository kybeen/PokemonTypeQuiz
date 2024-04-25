//
//  QuizViewModel.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/28/24.
//

import Foundation
import UIKit

import RxSwift
import RxRelay

final class QuizViewModel {
    
    // 포켓몬 데이터가 변경될 때마다 받아오는 Observable
    lazy var pokemonInfoObservable = BehaviorRelay<PokemonInfo>(value: .init(id: 0, koName: "none"))
    
    // 유저가 선택한 타입(인덱스) 배열
    /// 컬렉션 뷰에서 선택한 타입 셀의 인덱스 번호를 가지고 있다가 해당 값을 이후 PokemonType 값으로 변환
    var userTypeAnswer = [Int]()
    
    init() {
    }
}

// MARK: - 정답 처리

extension QuizViewModel {
    
    // 답변 유형
    enum AnswerType {
        case correct(type1: PokemonType, type2: PokemonType?) // 정답
        case noValue // 선택한 타입이 없음
        case fail // 오답
    }
    
    // 정답 제출 버튼 클릭 시 메서드
    func checkAnswer() -> AnswerType {
        if userTypeAnswer.count == 0 { // 선택한 타입이 없는 경우
            return .noValue
        } else {
            // 유저가 선택한 타입 값을 Int에서 PokemonType으로 변환
            let answerArr = convertIndexToPokemonType(userTypeAnswer: userTypeAnswer)
            if let type1Answer = pokemonInfoObservable.value.type1,
               let type2Answer = pokemonInfoObservable.value.type2 { // 포켓몬의 타입이 2개일 때
                // 둘 다 정답 배열에 있으면 정답
                if answerArr.contains(type1Answer) && answerArr.contains(type2Answer) {
                    return .correct(type1: type1Answer, type2: type2Answer)
                } else {
                    return .fail
                }
            } else { // 포켓몬의 타입이 1개일 때
                if answerArr.count == 2 { // 타입을 2개 골랐으면 틀림
                    return .fail
                } else {
                    if answerArr.contains(pokemonInfoObservable.value.type1!) {
                        return .correct(type1: pokemonInfoObservable.value.type1!, type2: pokemonInfoObservable.value.type2)
                    } else {
                        return .fail
                    }
                }
            }
        }
    }
    
    // 타입 인덱스가 들어 있는 정답 배열을 PokemonType 값이 들어 있는 배열로 바꿔서 반환하는 메서드
    func convertIndexToPokemonType(userTypeAnswer: [Int]) -> [PokemonType] {
        var pokemonTypeArr = [PokemonType]()
        for idx in userTypeAnswer {
            let value = PokemonType.allCases[idx]
            pokemonTypeArr.append(value)
        }
        return pokemonTypeArr
    }
}

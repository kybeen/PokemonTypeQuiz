//
//  AnswerUseCase.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 4/25/24.
//

import Foundation

import RxRelay
import RxSwift

final class AnswerUseCase {
    
    let userAnswer = BehaviorRelay(value: Set<Int>())
    let answerStatus = PublishRelay<AnswerStatus>()
    
    func selectType(_ idx: Int) {
        if userAnswer.value.contains(idx) {
            // 선택되어있는 값이면 userAnswer에서 제거
            removeValueFromUserAnswer(idx)
        } else {
            // 선택되어 있지 않은 값이고, userAnswer의 값이 2개 미만일 때 userAnswer에 추가
            if userAnswer.value.count < 2 {
                insertValueToUserAnswer(idx)
            }
        }
    }
    
    func checkAnswer(type1: PokemonType?, type2: PokemonType?) {
        if userAnswer.value.count == 0 { // 선택한 타입이 없는 경우
            answerStatus.accept(.noValue)
        } else {
            // 유저가 선택한 타입 값을 Int에서 PokemonType으로 변환
            let answerArr = convertIndexToPokemonType(userTypeAnswer: userAnswer.value)
            if let type1Answer = type1,
               let type2Answer = type2 { // 포켓몬의 타입이 2개일 때
                // 둘 다 정답 배열에 있으면 정답
                if answerArr.contains(type1Answer) && answerArr.contains(type2Answer) {
                    answerStatus.accept(.correct(type1: type1Answer, type2: type2Answer))
                    resetUserAnswer()
                } else {
                    answerStatus.accept(.fail)
                }
            } else { // 포켓몬의 타입이 1개일 때
                if answerArr.count == 2 { // 타입을 2개 골랐으면 틀림
                    answerStatus.accept(.fail)
                } else {
                    if answerArr.contains(type1!) {
                        answerStatus.accept(.correct(type1: type1!, type2: type2))
                        resetUserAnswer()
                    } else {
                        answerStatus.accept(.fail)
                    }
                }
            }
        }
    }
    
    // 타입 인덱스가 들어 있는 정답 배열을 PokemonType 값이 들어 있는 배열로 바꿔서 반환하는 메서드
    func convertIndexToPokemonType(userTypeAnswer: Set<Int>) -> [PokemonType] {
        var pokemonTypeArr = [PokemonType]()
        for idx in userTypeAnswer {
            let value = PokemonType.allCases[idx]
            pokemonTypeArr.append(value)
        }
        return pokemonTypeArr
    }
    
    // userAnswer에 선택한 타입 인덱스 값 추가
    private func insertValueToUserAnswer(_ idx: Int) {
        var newUserAnswer = userAnswer.value
        newUserAnswer.insert(idx)
        print("값 추가 \(newUserAnswer)")
        userAnswer.accept(newUserAnswer)
    }
    
    // userAnswer에서 선택한 타입 인덱스 값 제거
    private func removeValueFromUserAnswer(_ idx: Int) {
        var newUserAnswer = userAnswer.value
        newUserAnswer.remove(idx)
        print("값 제거 \(newUserAnswer)")
        userAnswer.accept(newUserAnswer)
    }
    
    // userAnswer 초기화
    func resetUserAnswer() {
        userAnswer.accept(Set<Int>())
    }
}

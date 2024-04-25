//
//  AnswerStatus.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 4/25/24.
//

// 결과 제출 상태 (채점 결과)
enum AnswerStatus {
    case correct(type1: PokemonType, type2: PokemonType?) // 정답
    case noValue // 선택한 타입이 없음
    case fail // 오답
}

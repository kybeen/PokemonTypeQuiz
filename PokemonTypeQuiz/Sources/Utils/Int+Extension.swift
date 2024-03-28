//
//  Int+Extension.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/27/24.
//

// MARK: - Int 익스텐션

extension Int {
    
    // 1~151 번 중에서 랜덤으로 도감 번호를 추출
    static var randomID: Self {
        Self.random(in: 0...151)
    }
}

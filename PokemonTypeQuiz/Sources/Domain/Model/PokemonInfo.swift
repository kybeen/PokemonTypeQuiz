//
//  PokemonInfo.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/27/24.
//

// MARK: - QuizView에서 필요한 포켓몬 정보 모델

struct PokemonInfo {
    var id: Int // 도감 번호
    var koName: String // 한글 이름
    var imageURL: String? // 이미지URL
    var type1: PokemonType? // 타입1
    var type2: PokemonType? // 타입2
}

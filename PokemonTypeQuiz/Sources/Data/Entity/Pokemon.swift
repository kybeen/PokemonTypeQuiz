//
//  Pokemon.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import Foundation

// MARK: - Data Transfer Object (DTO)
/// 👉 REST API 응답 객체

/**
 id: 도감번호
 name: 이름
 sprites: 종류 별 이미지 URL이 들어 있는 객체
 types: 포켓몬 타입 정보가 들어 있는 객체의 배열
 */
struct PokemonData: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [TypeElement?]
}

// 이미지 URL이 들어 있는 객체를 받기 위한 타입
/// null 값으로 오는 경우도 있음
struct Sprites: Codable {
    let backDefault: String?
    let backFemale: String?
    let backShiny: String?
    let backShinyFemale: String?
    let frontDefault: String? // MARK: - 기본 앞모습 (사용할 데이터)
    let frontFemale: String?
    let frontShiny: String?
    let frontShinyFemale: String?
    
    /// json파일의 데이터 이름과 프로퍼티의 이름이 다를 경우 필요한 설정
    private enum CodingKeys: String, CodingKey {
        case backDefault = "back_default"
        case backFemale = "back_female"
        case backShiny = "back_shiny"
        case backShinyFemale = "back_shiny_female"
        case frontDefault = "front_default"
        case frontFemale = "front_female"
        case frontShiny = "front_shiny"
        case frontShinyFemale = "front_shiny_female"
    }
}

// "types" 배열 값의 각 원소 (타입1, 타입2)
struct TypeElement: Codable {
    let slot: Int // 타입1, 타입2 구분
    let type: TypeInfo // 타입 정보
}
// 타입 정보
struct TypeInfo: Codable {
    let name: String // MARK: - 타입명 (사용할 데이터)
    let url: String // 타입에 해당하는 URI
}



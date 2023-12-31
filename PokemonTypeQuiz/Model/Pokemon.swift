//
//  Pokemon.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import Foundation

// MARK: - 응답으로 받을 객체
struct PokemonData: Codable {
    let id: Int // 도감번호
    let name: String // 이름
    let sprites: Sprites // 종류 별 이미지 URL이 들어 있는 객체
    let types: [TypeElement?] // 포켓몬 타입 정보가 들어 있는 객체의 배열
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

// 포켓몬 타입
enum PokemonType: String, CaseIterable {
    
    case normal
    case fighting
    case flying
    case poison
    case ground
    case rock
    case bug
    case ghost
    case steel
    case fire
    case water
    case grass
    case electric
    case psychic
    case ice
    case dragon
    case dark
    case fairy

    // 타입의 한글 이름을 반환
    var koType: String {
        switch self {
        case .normal:
            return "노말"
        case .fighting:
            return "격투"
        case .flying:
            return "비행"
        case .poison:
            return "독"
        case .ground:
            return "땅"
        case .rock:
            return "바위"
        case .bug:
            return "벌레"
        case .ghost:
            return "고스트"
        case .steel:
            return "강철"
        case .fire:
            return "불꽃"
        case .water:
            return "물"
        case .grass:
            return "풀"
        case .electric:
            return "전기"
        case .psychic:
            return "에스퍼"
        case .ice:
            return "얼음"
        case .dragon:
            return "드래곤"
        case .dark:
            return "악"
        case .fairy:
            return "페어리"
        }
    }
}

extension String {

    // 문자열의 앞글자만 대문자로 바꿔주는 메서드 (프로필 이미지 초기화에 필요)
    func capitalized() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

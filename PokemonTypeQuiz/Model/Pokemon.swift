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

// 타입 영어이름
let englishType = [
    "normal", "fighting", "flying", "poison", "ground", "rock", "bug",
    "ghost", "steel", "fire", "water", "grass", "electric", "psychic",
    "ice", "dragon", "dark", "fairy"
]
// 타입 한글이름
let koreanType = [
    "노말", "격투", "비행", "독", "땅", "바위", "벌레", "고스트", "강철", "불꽃",
    "물", "풀", "전기", "에스퍼", "얼음", "드래곤", "악", "페어리"
]

let enToKoTypeDict = [
    "normal": "노말",
    "fighting": "격투",
    "flying": "비행",
    "poison": "독",
    "ground": "땅",
    "rock": "바위",
    "bug": "벌레",
    "ghost": "고스트",
    "steel": "강철",
    "fire": "불꽃",
    "water": "물",
    "grass": "풀",
    "electric": "전기",
    "psychic": "에스퍼",
    "ice": "얼음",
    "dragon": "드래곤",
    "dark": "악",
    "fairy": "페어리"
]

//// 포켓몬 타입
//enum PokemonType: String, CaseIterable {
//    case normal = "노말"
//    case fighting = "격투"
//    case flying = "비행"
//    case poison = "독"
//    case ground = "땅"
//    case rock = "바위"
//    case bug = "벌레"
//    case ghost = "고스트"
//    case steel = "강철"
//    case fire = "불꽃"
//    case water = "물"
//    case grass = "풀"
//    case electric = "전기"
//    case psychic = "에스퍼"
//    case ice = "얼음"
//    case dragon = "드래곤"
//    case dark = "악"
//    case fairy = "페어리"
//
//}

extension String {

    // 문자열의 앞글자만 대문자로 바꿔주는 메서드 (프로필 이미지 초기화에 필요)
    func capitalized() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

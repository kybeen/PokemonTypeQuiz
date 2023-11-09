//
//  Pokemon.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import Foundation

struct Pokemon {
    var id: Int // 도감번호
    var name: String // 이름
    var imageURL: String // 이미지
//    var type1: PokemonType // 타입1
//    var type2: PokemonType? // 타입2
    var type1: String // 타입1
    var type2: String? // 타입2
}

let englishType = [
    "normal", "fighting", "flying", "poison", "ground", "rock", "bug",
    "ghost", "steel", "fire", "water", "grass", "electric", "psychic",
    "ice", "dragon", "dark", "fairy"
]
let koreanType = [
    "노말", "격투", "비행", "독", "땅", "바위", "벌레", "고스트", "강철", "불꽃",
    "물", "풀", "전기", "에스퍼", "얼음", "드래곤", "악", "페어리"
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
////    var dayString: String {
////        switch self {
////        case .mon: return "월"
////        case .tue: return "화"
////        case .wed: return "수"
////        case .thu: return "목"
////        case .fri: return "금"
////        case .sat: return "토"
////        case .sun: return "일"
////        }
////    }
//}
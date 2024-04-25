//
//  PokemonType.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/27/24.
//

// MARK: - 포켓몬 타입

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

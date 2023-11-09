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

let enToKoNameDict = ["Kabutops": "투구푸스", "Venusaur": "이상해꽃", "Starmie": "아쿠스타", "Snorlax": "잠만보", "Koffing": "또가스", "Psyduck": "고라파덕", "Golem": "딱구리", "Farfetch’d": "파오리", "Mankey": "망키", "Shellder": "셀러", "Electrode": "붐볼", "Nidorino": "니드리노", "Nidoran♀": "니드런♀", "Zubat": "주뱃", "Fearow": "깨비드릴조", "Sandshrew": "모래두지", "Dodrio": "두트리오", "Exeggcute": "아라리", "Ekans": "아보", "Hypno": "슬리퍼", "Geodude": "꼬마돌", "Voltorb": "찌리리공", "Rhydon": "코뿌리", "Gyarados": "갸라도스", "Kabuto": "투구", "Caterpie": "캐터피", "Blastoise": "거북왕", "Tangela": "덩쿠리", "Tauros": "켄타로스", "Poliwhirl": "슈륙챙이", "Grimer": "질퍽이", "Pidgey": "구구", "Alakazam": "후딘", "Jolteon": "쥬피썬더", "Sandslash": "고지", "Pikachu": "피카츄", "Clefable": "픽시", "Vaporeon": "샤미드", "Nidoqueen": "니드퀸", "Dugtrio": "닥트리오", "Lapras": "라프라스", "Primeape": "성원숭", "Graveler": "데구리", "Charizard": "리자몽", "Ninetales": "나인테일", "Exeggutor": "나시", "Poliwag": "발챙이", "Chansey": "럭키", "Tentacool": "왕눈해", "Lickitung": "내루미", "Venomoth": "도나리", "Ditto": "메타몽", "Magneton": "레어코일", "Porygon": "폴리곤", "Pidgeot": "피죤투", "Mewtwo": "뮤츠", "Bulbasaur": "이상해씨", "Doduo": "두두", "Seadra": "시드라", "Raticate": "레트라", "Magikarp": "잉어킹", "Machop": "알통몬", "Drowzee": "슬리프", "Metapod": "단데기", "Wartortle": "어니부기", "Diglett": "디그다", "Jynx": "루주라", "Omastar": "암스타", "Dragonite": "망나뇽", "Zapdos": "썬더", "Vileplume": "라플레시아", "Spearow": "깨비참", "Squirtle": "꼬부기", "Slowbro": "야도란", "Machamp": "괴력몬", "Kakuna": "딱충이", "Abra": "캐이시", "Hitmonlee": "시라소몬", "Bellsprout": "모다피", "Gengar": "팬텀", "Nidorina": "니드리나", "Goldeen": "콘치", "Aerodactyl": "프테라", "Cloyster": "파르셀", "Cubone": "탕구리", "Dragonair": "신뇽", "Flareon": "부스터", "Mr. Mime": "마임맨", "Rapidash": "날쌩마", "Paras": "파라스", "Horsea": "쏘드라", "Kangaskhan": "캥카", "Gloom": "냄새꼬", "Dratini": "미뇽", "Onix": "롱스톤", "Jigglypuff": "푸린", "Charmeleon": "리자드", "Pinsir": "쁘사이저", "Moltres": "파이어", "Articuno": "프리져", "Dewgong": "쥬레곤", "Machoke": "근육몬", "Kadabra": "윤겔라", "Vulpix": "식스테일", "Charmander": "파이리", "Magnemite": "코일", "Ponyta": "포니타", "Nidoran♂": "니드런♂", "Parasect": "파라섹트", "Muk": "질뻐기", "Weepinbell": "우츠동", "Marowak": "텅구리", "Wigglytuff": "푸크린", "Tentacruel": "독파리", "Pidgeotto": "피죤", "Krabby": "크랩", "Hitmonchan": "홍수몬", "Staryu": "별가사리", "Omanyte": "암나이트", "Mew": "뮤", "Arcanine": "윈디", "Eevee": "이브이", "Poliwrath": "강챙이", "Magmar": "마그마", "Nidoking": "니드킹", "Ivysaur": "이상해풀", "Clefairy": "삐삐", "Golbat": "골뱃", "Slowpoke": "야돈", "Beedrill": "독침붕", "Haunter": "고우스트", "Arbok": "아보크", "Rhyhorn": "뿔카노", "Seel": "쥬쥬", "Persian": "페르시온", "Gastly": "고오스", "Raichu": "라이츄", "Victreebel": "우츠보트", "Rattata": "꼬렛", "Weedle": "뿔충이", "Growlithe": "가디", "Kingler": "킹크랩", "Seaking": "왕콘치", "Electabuzz": "에레브", "Meowth": "나옹", "Venonat": "콘팡", "Golduck": "골덕", "Oddish": "뚜벅쵸", "Butterfree": "버터플", "Scyther": "스라크", "Weezing": "또도가스"]

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

extension String {

    // 문자열의 앞글자만 대문자로 바꿔주는 메서드 (프로필 이미지 초기화에 필요)
    func capitalized() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

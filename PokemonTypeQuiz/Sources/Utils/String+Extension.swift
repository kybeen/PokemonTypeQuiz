//
//  String+Extension.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/27/24.
//

// MARK: - String 익스텐션
extension String {

    // 문자열의 앞글자만 대문자로 바꿔주는 메서드 (프로필 이미지 초기화에 필요)
    func capitalized() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}

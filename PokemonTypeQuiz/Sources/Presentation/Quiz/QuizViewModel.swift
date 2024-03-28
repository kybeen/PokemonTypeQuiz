//
//  QuizViewModel.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/28/24.
//

import Foundation
import UIKit

import RxSwift
import RxRelay

final class QuizViewModel {
    
    var pokemonNameDictionary = [String:String]() // 영어:한글 쌍의 포켓몬 이름 딕셔너리
    
    // 포켓몬 데이터가 변경될 때마다 받아오는 Observable
    lazy var pokemonInfoObservable = BehaviorRelay<PokemonInfo>(value: .init(id: 0, koName: "none"))
    
    // 유저가 선택한 타입(인덱스) 배열
    /// 컬렉션 뷰에서 선택한 타입 셀의 인덱스 번호를 가지고 있다가 해당 값을 이후 PokemonType 값으로 변환
    var userTypeAnswer = [Int]()
    
    init() {
        // 번역된 포켓몬 이름 CSV 데이터 불러오기
        loadPokemonNameCSV()
    }
}

// MARK: - 포켓몬 정보 불러오기

extension QuizViewModel {
    
    // 1~151 번 사이의 포켓몬을 랜덤으로 불러오는 메서드
    func loadRandomPokemon() {
        _ = PokemonAPIService.fetchPokemonInfoRx(id: Int.randomID)
            .map { [weak self] data in
                let pokemonDTO = try! JSONDecoder().decode(PokemonDTO.self, from: data)
                var type1: PokemonType?
                var type2: PokemonType?
                // 타입 확인
                if let type = pokemonDTO.types[0] {
                    type1 = PokemonType(rawValue: type.type.name)
                }
                if pokemonDTO.types.count > 1 {
                    if let type = pokemonDTO.types[1] {
                        type2 = PokemonType(rawValue: type.type.name)
                    }
                }
                let pokemonInfo = PokemonInfo(
                    id: pokemonDTO.id,
                    koName: self?.pokemonNameDictionary[pokemonDTO.name.capitalized] ?? pokemonDTO.name,
                    imageURL: pokemonDTO.sprites.frontDefault,
                    type1: type1,
                    type2: type2
                )
                return pokemonInfo
            }
            .take(1)
            .bind(to: pokemonInfoObservable)
    }
    
    // 포켓몬 이미지를 불러오는 메서드
    func fetchPokemonImage(for url: String) async throws -> UIImage {
        let request = URLRequest(url: URL(string: url)!)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        let image = UIImage(data: data)
        guard let image = image else{
            throw ImageError.invalidData
        }
        return image
    }
}

// MARK: - CSV 처리

extension QuizViewModel {
    
    // 번역된 포켓몬 이름 CSV 데이터를 불러오는 메서드
    private func loadPokemonNameCSV() {
        print("loadPokemonNameCSV()...")
        let path = Bundle.main.path(forResource: "pokemonNames", ofType: "csv")!
        print(path)

        parseCSV(url: URL(fileURLWithPath: path))
    }
    
    // CSV 파일을 파싱하는 메서드
    private func parseCSV(url: URL) {
        print("parseCSV()...")
        let data = try? Data(contentsOf: url) /// Data(contentsOf:) 는 동기적으로 작동함 👉 메인 스레드를 잡아먹기 때문에 네트워크 통신에서는 사용하지 맙시다
        guard let data = data else {
            print("CSV 파일을 불러오지 못함")
            return
        }
        print("CSV 파일을 불러왔습니다!!")
        if let dataEncoded = String(data: data, encoding: .utf8) {
            var lines = dataEncoded.components(separatedBy: "\n")
            lines.removeFirst()
            
            var koName = ""
            var enName = ""
            for line in lines {
                let columns = line.components(separatedBy: ",")
                guard columns.count == 4 else {
                    break
                }
                if columns[1] == "3" {
                    koName = columns[2]
                } else if columns[1] == "9" {
                    enName = columns[2]
                    pokemonNameDictionary[enName] = koName
                }
            }
        }
    }
}

// MARK: - 정답 처리

extension QuizViewModel {
    
    // 답변 유형
    enum AnswerType {
        case correct(type1: PokemonType, type2: PokemonType?) // 정답
        case noValue // 선택한 타입이 없음
        case fail // 오답
    }
    
    // 정답 제출 버튼 클릭 시 메서드
    func checkAnswer() -> AnswerType {
        if userTypeAnswer.count == 0 { // 선택한 타입이 없는 경우
            return .noValue
        } else {
            // 유저가 선택한 타입 값을 Int에서 PokemonType으로 변환
            let answerArr = convertIndexToPokemonType(userTypeAnswer: userTypeAnswer)
            if let type1Answer = pokemonInfoObservable.value.type1,
               let type2Answer = pokemonInfoObservable.value.type2 { // 포켓몬의 타입이 2개일 때
                // 둘 다 정답 배열에 있으면 정답
                if answerArr.contains(type1Answer) && answerArr.contains(type2Answer) {
                    return .correct(type1: type1Answer, type2: type2Answer)
                } else {
                    return .fail
                }
            } else { // 포켓몬의 타입이 1개일 때
                if answerArr.count == 2 { // 타입을 2개 골랐으면 틀림
                    return .fail
                } else {
                    if answerArr.contains(pokemonInfoObservable.value.type1!) {
                        return .correct(type1: pokemonInfoObservable.value.type1!, type2: pokemonInfoObservable.value.type2)
                    } else {
                        return .fail
                    }
                }
            }
        }
    }
    
    // 타입 인덱스가 들어 있는 정답 배열을 PokemonType 값이 들어 있는 배열로 바꿔서 반환하는 메서드
    func convertIndexToPokemonType(userTypeAnswer: [Int]) -> [PokemonType] {
        var pokemonTypeArr = [PokemonType]()
        for idx in userTypeAnswer {
            let value = PokemonType.allCases[idx]
            pokemonTypeArr.append(value)
        }
        return pokemonTypeArr
    }
}

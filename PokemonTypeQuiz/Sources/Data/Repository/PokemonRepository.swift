//
//  PokemonRepository.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 4/25/24.
//

import Foundation

import RxSwift

final class PokemonRepository {
    var pokemonNameDictionary = [String: String]()
    
    init() {
        // 포켓몬 이름 딕셔너리 생성
        // TODO: - 옵셔널 바인딩으로 수정하고 오류처리 필요
        print("loadPokemonNameCSV()...")
        let path = Bundle.main.path(forResource: "pokemonNames", ofType: "csv")!
        print(path)
        let url =  URL(fileURLWithPath: path)
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

extension PokemonRepository: PokemonRepositoryProtocol {
    
    // 랜덤 포켓몬 불러오기
    func getRandomPokemon() -> Observable<PokemonInfo> {
        return Observable.create() { emitter in
            PokemonAPIService.fetchPokemonData(id: Int.randomID) { result in
                switch result {
                case .success(let data):
                    print("[PokemonRepository] 랜덤 포켓몬 불러옴!!")
                    guard let pokemonDTO = try? JSONDecoder().decode(PokemonDTO.self, from: data) else {
                        emitter.onError(PokemonDTOError.decodingError)
                        return
                    }
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
                        koName: self.pokemonNameDictionary[pokemonDTO.name.capitalized] ?? pokemonDTO.name,
                        imageURL: pokemonDTO.sprites.frontDefault,
                        type1: type1,
                        type2: type2
                    )
                    emitter.onNext(pokemonInfo)
                    emitter.onCompleted()
                case .failure(let error):
                    print("[PokemonRepository] 랜덤 포켓몬 불러오기 실패")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    // 포켓몬 이미지 데이터 불러오기
    func getPokemonImage(imageURL: String) -> Observable<Data> {
        return Observable.create() { emitter in
            PokemonAPIService.fetchPokemonImageData(imageUrl: imageURL) { result in
                switch result {
                case .success(let imageData):
                    print("[PokemonRepository] 포켓몬 이미지 불러옴!!")
                    emitter.onNext(imageData)
                    emitter.onCompleted()
                case .failure(let error):
                    print("[PokemonRepository] 포켓몬 이미지 불러오기 실패")
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    
}

//
//  RandomPokemonUseCase.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 4/25/24.
//

import Foundation

import RxCocoa
import RxRelay
import RxSwift

final class RandomPokemonUseCase {
    
    private let pokemonRepository: PokemonRepositoryProtocol
    
    let pokemonInfo = PublishRelay<PokemonInfo>()
    let pokemonImageData = PublishRelay<Data>()
    
    private let disposeBag = DisposeBag()
    
    init(_ pokemonRepository: PokemonRepositoryProtocol) {
        self.pokemonRepository = pokemonRepository
        
    }
    
    func loadRandomPokemon() {
        print("[RandomPokemonUseCase] 랜덤 포켓몬 불러오기!!")
        pokemonRepository.getRandomPokemon()
            .do(onNext: { [weak self] pokemonInfo in
                if let imageURL = pokemonInfo.imageURL {
                    self?.loadPokemonImage(imageURL: imageURL)
                }
            })
            .bind(to: pokemonInfo)
            .disposed(by: disposeBag)
    }
    
    func loadPokemonImage(imageURL: String) {
        print("[RandomPokemonUseCase] 포켓몬 이미지 불러오기!!")
        pokemonRepository.getPokemonImage(imageURL: imageURL)
            .bind(to: pokemonImageData)
            .disposed(by: disposeBag)
    }
}

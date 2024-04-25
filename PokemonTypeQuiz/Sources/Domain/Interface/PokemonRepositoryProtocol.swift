//
//  PokemonRepositoryProtocol.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 4/25/24.
//

import Foundation

import RxSwift

protocol PokemonRepositoryProtocol {
    func getRandomPokemon() -> Observable<PokemonInfo>
    func getPokemonImage(imageURL: String) -> Observable<Data>
}

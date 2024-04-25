//
//  PokemonAPIService.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/27/24.
//

import Foundation

// 에러 타입
enum NetworkRequestError: Error {
    case invalidURL
    case requestFail
    case noData
}
enum PokemonDTOError: Error {
    case decodingError
}
//enum ImageError: Error {
//    case invalidImage
//}
enum CSVError: Error {
    case noData
    case encodingError
}

final class PokemonAPIService {
    
    static func fetchPokemonData(id: Int, completionHandler: @escaping (Result<Data, NetworkRequestError>) -> Void) {
        let pokemonURL = "https://pokeapi.co/api/v2/pokemon/\(id)"
        guard let url = URL(string: pokemonURL) else {
            completionHandler(.failure(NetworkRequestError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completionHandler(.failure(NetworkRequestError.requestFail))
            }
            guard let data = data else {
                completionHandler(.failure(NetworkRequestError.noData))
                return
            }
            completionHandler(.success(data))
        }.resume()
    }
    
    static func fetchPokemonImageData(imageUrl: String, completionHandler: @escaping (Result<Data, NetworkRequestError>) -> Void) {
        guard let url = URL(string: imageUrl) else {
            completionHandler(.failure(NetworkRequestError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                completionHandler(.failure(NetworkRequestError.requestFail))
            }
            guard let data = data else {
                completionHandler(.failure(NetworkRequestError.noData))
                return
            }
            completionHandler(.success(data))
        }.resume()
    }
}

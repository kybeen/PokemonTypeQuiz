//
//  PokemonAPIService.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 3/27/24.
//

import Foundation
import UIKit

import RxSwift

// 에러 타입
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
}
enum ImageError: Error {
    case invalidData
}

final class PokemonAPIService {
    
    static func fetchPokemonInfo(id: Int, completionHandler: @escaping (Result<Data, Error>) -> Void) {
        let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            }
            guard let data = data else {
                let httpResponse = response as! HTTPURLResponse
                completionHandler(.failure(NSError(domain: "no data", code: httpResponse.statusCode)))
                return
            }
            completionHandler(.success(data))
        }.resume()
    }
    
    static func fetchPokemonImage(url: String, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            }
            guard let data = data else {
                let httpResponse = response as! HTTPURLResponse
                completionHandler(.failure(NSError(domain: "no image", code: httpResponse.statusCode)))
                return
            }
            let image = UIImage(data: data)
            guard let image = image else {
                completionHandler(.failure(ImageError.invalidData))
                return
            }
            completionHandler(.success(image))
        }
    }
    
    static func fetchPokemonInfoRx(id: Int) -> Observable<Data> {
        return Observable.create() { emitter in
            
            fetchPokemonInfo(id: id) { result in
                switch result {
                case .success(let data):
                    emitter.onNext(data)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
    
    static func fetchPokemonImageRx(url: String) -> Observable<UIImage> {
        return Observable.create() { emitter in
            
            fetchPokemonImage(url: url) { result in
                switch result {
                case .success(let pokemonImage):
                    emitter.onNext(pokemonImage)
                    emitter.onCompleted()
                case .failure(let error):
                    emitter.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}



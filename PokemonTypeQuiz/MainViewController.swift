//
//  MainViewController.swift
//  PokemonTypeQuiz
//
//  Created by 김영빈 on 2023/11/09.
//

import UIKit

import SnapKit

class MainViewController: UIViewController {

    private let mainView = MainView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let id = 4
        let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
        let apiURI: URL! = URL(string: url)
        
        let apiData = try! Data(contentsOf: apiURI)
        
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apiData, options: []) as! NSDictionary
            
            // 도감번호
            let id = apiDictionary["id"]
            print("id: \(id)")

            // 영문이름
            let name = apiDictionary["name"]
            print("name: \(name)")

            // 이미지 URL
            let sprites = apiDictionary["sprites"] as! NSDictionary
            let imageURL = sprites["front_default"] as! String
            print("imageURL: \(imageURL)")

            // 타입1
            let typesArr = apiDictionary["types"] as! NSArray
            let type1Value: String = {
                let dict = typesArr[0] as! NSDictionary
                let dict2 = dict["type"] as! NSDictionary
                let type1 = dict2["name"] as! String
                return type1
            }()
            print("type1Value: \(type1Value)")
            
            // 타입2
            var type2Value: String?
            if typesArr.count > 1 {
                let dict = typesArr[1] as! NSDictionary
                let dict2 = dict["type"] as! NSDictionary
                let type2 = dict2["name"] as! String
                type2Value = type2
            }
            print("type2Value: \(type2Value)")
        } catch {
            print("오류")
        }
    }
}

# PokemonTypeQuiz
포켓몬 API를 활용한 포켓몬 타입 퀴즈

### ✈️ 테스트플라이트
<img width="200" alt="image" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/63093d51-b7af-441d-bde0-39412a3f8e04">



### 💡 활용 API
- 포켓몬 API 👉 https://pokeapi.co
- Docs 👉 https://pokeapi.co/docs/v2#items-section

### 📑 언어별 이름 파일
- https://github.com/PokeAPI/pokeapi/blob/master/data/v2/csv/pokemon_species_names.csv
- CSV 파일 다운 후 앱에서 파싱해서 번역

  <img width="300" alt="image" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/3a24ac3e-68a2-46c3-afa9-4bfb98c60598">


### ⚙️ 동작 방식
1. 랜덤으로 관동지방(도감번호 1~151)의 포켓몬 중 한마리의 이름과 이미지를 불러온다.
2. 타입을 선택하고 정답을 제출



## 엔드포인트 & 데이터 구조

*https://pokeapi.co/api/v2/pokemon/{도감번호}*
- HTTP GET 메서드만 지원
- ex) 이상해씨(도감번호 1번) 👉 https://pokeapi.co/api/v2/pokemon/1
    - **응답 결과** (포켓몬 특성, 서식지, 등장 시리즈 등 엄청나게 많은 양의 응답이 들어온다. 필요한 것만 골라쓰기)
      
      <img width="500" alt="1" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/c63e2618-f83d-4e7e-b068-f9315dde32cb">


    - **이름 ( `name` )**
      
      <img width="400" alt="name" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/aeafa187-892e-4c93-b867-bf68932d6d3b">


    - **이미지URL ( `sprites` > `front_default` )**
      
      <img width="400" alt="image" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/ed37a2a7-a9c3-4cd9-a898-eeb48a4a96da">
      <img width="400" alt="image2" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/dec68643-3550-4ec5-bc71-47f43d5df500">


    - **타입 ( `types` > 배열element > `type` > `name` )**
      
      <img width="400" alt="type" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/0a7c865c-91bd-4ee7-921b-f83ff45d8ee9">

## 코드
### 💡 도감번호 1~151 랜덤 추출 & 도감 번호에 해당하는 포켓몬 불러오기
```
// MARK: - 도감 번호 랜덤 추출
private func randomIDGenerator() -> Int {
    // 1~151 번 중에서 랜덤
    let randomNumber = Int.random(in: 0...151)
    return randomNumber
}

// MARK: - 랜덤 포켓몬 불러오기
private func loadRandomPokemon(id: Int) {
    // id 도감번호에 해당하는 포켓몬을 호출하기 위한 엔드포인트
    let url = "https://pokeapi.co/api/v2/pokemon/\(id)"
    guard let apiURI = URL(string: url) else { return }

    let session = URLSession(configuration: .default)
    session.dataTask(with: apiURI) { data, response, error in
        if let error = error {
            print("error: \(error)")
        }
        guard let data = data else {
            return
        }

        // 응답으로 받은 객체를 PokemonData 타입으로 디코딩해서 처리
        do {
            let pokemonData = try JSONDecoder().decode(PokemonData.self, from: data)
            DispatchQueue.main.async {

                // 도감 번호 처리
                self.mainView.pokemonID.text = "도감번호: \(pokemonData.id)"

                // 이름 처리
                // TODO: - 마임맨(mr-mime) 👉 예외처리 필요 (-가 있어서 딕셔너리 키값으로 검색이 안됨)
                let koreanName = self.pokemonNameDictionary[pokemonData.name.capitalized] // 한글 이름 매핑
                self.mainView.pokemonName.text = koreanName

                // 이미지 처리
                Task {
                    self.mainView.pokemonImageView.image = try await self.fetchPokemonImage(for: pokemonData.sprites.frontDefault!)
                }
                
                // 타입1 처리
                if let type1 = pokemonData.types[0] {
                    self.type1Answer = PokemonType(rawValue: type1.type.name)
                }
                // 타입2 처리
                if pokemonData.types.count > 1 {
                    if let type2 = pokemonData.types[1] {
                        self.type2Answer = PokemonType(rawValue: type2.type.name)
                    }
                }
            }
        } catch {
            print("에러")
        }
    }.resume()
}
```

### 💡 포켓몬 데이터 모델 정의
```
// MARK: - 응답으로 받을 객체
/**
 id: 도감번호
 name: 이름
 sprites: 종류 별 이미지 URL이 들어 있는 객체
 types: 포켓몬 타입 정보가 들어 있는 객체의 배열
 */
struct PokemonData: Codable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [TypeElement?]
}

// 이미지 URL이 들어 있는 객체를 받기 위한 타입
/// null 값으로 오는 경우도 있음
struct Sprites: Codable {
    let backDefault: String?
    let backFemale: String?
    let backShiny: String?
    let backShinyFemale: String?
    let frontDefault: String? // MARK: - 기본 앞모습 (사용할 데이터)
    let frontFemale: String?
    let frontShiny: String?
    let frontShinyFemale: String?
    
    /// json파일의 데이터 이름과 프로퍼티의 이름이 다를 경우 필요한 설정
    private enum CodingKeys: String, CodingKey {
        case backDefault = "back_default"
        case backFemale = "back_female"
        case backShiny = "back_shiny"
        case backShinyFemale = "back_shiny_female"
        case frontDefault = "front_default"
        case frontFemale = "front_female"
        case frontShiny = "front_shiny"
        case frontShinyFemale = "front_shiny_female"
    }
}

// "types" 배열 값의 각 원소 (타입1, 타입2)
struct TypeElement: Codable {
    let slot: Int // 타입1, 타입2 구분
    let type: TypeInfo // 타입 정보
}
// 타입 정보
struct TypeInfo: Codable {
    let name: String // MARK: - 타입명 (사용할 데이터)
    let url: String // 타입에 해당하는 URI
}
```




## 📱 결과
<img width="250" alt="type" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/4547336a-fdf8-4358-aa1e-2408fadb0c1e">






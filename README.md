# PokemonTypeQuiz
포켓몬 API를 활용한 포켓몬 타입 퀴즈


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


## 📱 결과
<img width="250" alt="type" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/37f69dcd-7e56-4c20-b2ad-19c23932d88a">
<img width="250" alt="type" src="https://github.com/kybeen/PokemonTypeQuiz/assets/89764127/4547336a-fdf8-4358-aa1e-2408fadb0c1e">






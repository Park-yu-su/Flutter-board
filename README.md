# SSU게더


**개발 기간: 2024.08.01 ~ 2024.08.25**

## 프로젝트 소개

게시판&채팅 기능을 제공하는 **SSU게더** 게시판입니다.

인터넷에 존재하는 다양한 게시판들의 작동 방법 및 기능들을 알아보고자 진행한  
개인 토이 프로젝트입니다.


#### ▶ SSU게더는 다음과 같은 기능을 제공합니다.

##### (1) 회원가입&로그인

게시판, 채팅에서는 사용자가 누구인지 확인하는 것이 제일 중요합니다.
회원가입을 통해 유저 정보를 생성하고, 생성된 유저 정보를 통해 게시글을 작성&수정할 수 있습니다.


##### (2) 게시판 및 게시글 작성

본 프로젝트의 주요 기능으로, 직접 사용자가 게시글을 작성하고 작성한 글들을
속성에 맞게 분류하여 화면 상에 보여줍니다.

게시글을 최신 순으로 게시되며, 작성자는 자신이 작성한 게시글을 수정&삭제할 수 있습니다.

##### (3) 라이브 채팅

다수의 인원이 참여할 수 있는 채팅방으로  
카카오톡처럼 대화를 입력해 실시간으로 다른 사용자와 이야기를 나눌 수 있습니다.

##### (4) 달력

기본적인 달력 기능을 제공하며  
로그인한 경우, 유저별로 달력에 일정을 추가, 삭제, 수정할 수 있습니다.


---

## UI 구성

#### ▶ 메인 화면(게시판)
<img height="300" alt="image" src="https://github.com/user-attachments/assets/d503901b-2fe6-4c09-b2ed-343ca6eb015e">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/32603bf4-4d33-42b9-b136-b9462543daba">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/0c0cd9ab-ddc8-420c-a6fd-3971398b164c">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/5ca329a9-3eb7-411b-ab90-92f1ddbdde07">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/bafcc351-8b11-422f-b0a5-a11666a39961">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/e28321bb-10fe-4100-87a6-d2368d59d424">

- 작성된 게시글을 분류, 제목, 작성자, 작성 날짜로 정리하여 최신순으로 보여줍니다.
- 상단의 탭바를 통해 작성된 게시글들을 분류하여 볼 수 있습니다.
- 게시글들은 10개 단위로 한 화면에 존재하며, 하단의 버튼을 통해 페이지를 이동하여 게시글들을 볼 수 있습니다.
- 좌측 상단의 **돋보기 버튼**을 눌러 하단에 검색 창을 띄울 수 있고, 제목/내용/작성자 등을 필터링하여 게시글을 검색할 수 있습니다.
- 로그인한 경우, 우측 상단의 **연필 버튼**을 눌러 게시글을 작성할 수 있습니다.

</br>

#### ▶ 게시글 화면
<img height="300" alt="image" src="https://github.com/user-attachments/assets/b7e012dd-2435-4f62-9ac2-9a22dd08b0e0">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/b7fc1839-a159-4baa-814c-f984510bc634">

- 게시판에서 게시글을 터치하면 해당 화면으로 이동하며, 작성한 게시글의 세부 내용을 확인할 수 있습니다.
- 작성자의 경우 우측 상단의 **수정, 삭제 버튼**을 통해 게시글을 수정 및 삭제할 수 있습니다.
- 로그인한 유저는 하단의 텍스트바를 이용해 댓글을 작성할 수 있습니다.

</br>

#### ▶ 게시글 작성/수정 화면
<img height="300" alt="image" src="https://github.com/user-attachments/assets/4571c3c7-25d4-4535-b551-32b132454d70">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/6a3222cf-1f70-4668-be67-9bfc7384aa17">

- 제일 상단의 탭바를 통해 작성할 게시글의 속성을 선택할 수 있습니다.
- 수정의 경우, 기존에 작성한 내용이 불러와지며 해당 내용을 수정한 뒤 **수정 버튼**을 통해 내용을 수정할 수 있습니다.

</br>

#### ▶ 마이페이지(로그인/회원가입 화면)

<img height="300" alt="image" src="https://github.com/user-attachments/assets/6ac86ff4-00f8-45af-8819-0096a7694e79">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/9a05850a-3f20-4776-9ebb-944f03912922">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/4a32fb72-b21b-4a37-8625-73839fd5d6a6">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/7def9974-ba30-4acc-860a-f30b5f5dee4d">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/c74c7009-aec5-4d0b-ad69-1739dbccccf3">

- 처음 실행할 경우, 기본 화면이 뜨며 **로그인/회원가입** 버튼을 이용해 로그인 및 회원가입을 진행할 수 있습니다.
- 로그인한 유저의 경우, 프로필 아이콘을 터치하면, 사용자의 휴대폰에 있는 이미지를 가져와 프로필을 꾸밀 수 있습니다.
- 회원가입의 경우, Firebase Authentication을 이용하여 사용자를 추가/관리하는 방법을 이용했습니다.
- 비밀번호를 입력한 후 재차 확인 작업을 거쳐야 회원가입 버튼이 활성화되도록 구현했습니다.

</br>

#### ▶ 라이브 채팅 화면

<img height="300" alt="image" src="https://github.com/user-attachments/assets/6ee10596-25b9-40a3-85b9-455a795abe53">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/a36c7042-d9cb-4574-a525-fa290426af2a">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/f31c5a34-c55a-40f5-aabd-47ab30bf9e81">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/cdb51d81-b588-4ab1-9ac8-9f92aebc0ca6">

- UI 화면은 카카오톡의 채팅방 화면을 차용했습니다.
- 로그인한 경우, 채팅을 작성할 수 있으며, 작성자는 우측, 그 외 유저들은 좌측에 텍스트바가 출력됩니다.
- 로그인하지 않은 유저도 채팅을 확인할 수는 있지만, 작성은 불가능하도록 구현했습니다.

</br>

#### ▶ 달력 화면

<img height="300" alt="image" src="https://github.com/user-attachments/assets/9e34f088-ceb4-486f-a3e7-953b54a3b41f">
<img height="300" alt="image" src="https://github.com/user-attachments/assets/acaad444-42e5-4cfc-b1e2-c52f37913692">

- 날짜를 선택하면 해당 날짜가 선택되며, 하단의 텍스트바를 이용해 일정을 추가할 수 있습니다.
- 날짜가 선택된 상태에서 한 번 더 터치되면, 해당 날짜에 작성된 일정들을 확인할 수 있습니다.
- 위의 화면에서 일정의 추가 및 삭제를 할 수 있습니다.


---

#### ▶ 프로젝트 후기

Flutter 스터디를 하던 중, 단순히 인터넷에서 보이는 게시판이 어떻게 작동할까라는 호기심에서 프로젝트를 시작하게 되었고, 처음에는 게시판 기능 하나만 구현하려고 계획하였지만, '이 기능은 어떻게 구현할 수 있을까?' 라는 생각에 하나 둘 기능을 추가하게 되었고, 최종적으로 총 4가지 기능을 구현하게 되었습니다.

개발하기에 앞서, 게시판 UI 및 구현해야 하는 기능들을 알기 위해 여러 인터넷 사이트의 게시판들을 보며 필수 기능들은 무엇인지 정리하고, 이를 구현하기 위해서는 어떻게 접근해야 할지 고민했습니다. 

처음으로 진행한 프로젝트인 만큼, 얻은 정보를 취합하여 대략적으로 UI도 그려보며 구상하고 진행한 만큼 나름의 계획?을 세우고 프로젝트를 진행했습니다.

<img height="400" alt="image" src="https://github.com/user-attachments/assets/d0038d3b-35d7-4147-8d5d-e94220cd80b8">
<img height="400" alt="image" src="https://github.com/user-attachments/assets/c3f51fca-8fea-43b4-b9ab-898c1b09f104">
<img height="400" alt="image" src="https://github.com/user-attachments/assets/92512031-8d28-4407-8bfe-51c0b7d272f8">


그러나 처음 프로젝트를 진행하니 미숙한 점도 많았고, 많은 시행착오을 겪었습니다.  
git 사용에 미숙해, branch도 master 하나로만 진행하였고, 기능 하나를 완성하여도 자체 QA를 진행할 때마다 예상하지 못한 오류들이 발생하여, 기능을 계속 수정하였습니다. 


특히, 데이터베이스에 대해 무지했기 때문에, 단순히 데이터베이스에 정보만 저장하면 끝이라고 생각하고 개발에 임했습니다. 하지만 **게시글을 알맞게 분리해 데이터베이스에 저장하는 방법**부터 **수정과 삭제의 실제 작동 방식** 등 고려해야 하는 요소들이 많다는 것을 뒤늦게 알게 되었고,
막상 구현이 끝내고 보니 실제로 이를 상용화 하기에는 너무 비효율적으로 데이터베이스를 운용한 것을 깨닫게 되었습니다. 
 

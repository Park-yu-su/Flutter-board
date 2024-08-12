class BoardContent {
  String title; //제목
  String content; //본문
  String author; //글쓴이
  DateTime time; //시간
  String attribute; //속성(타입)
  List<Map<String, dynamic>> comments; //댓글
  int watch; //본 수
  String id; //해당 글의 ID

  /*
  주의할 점
  본문에 있는 time은 DateTime 형태를 사용하기에 firestore에서 timestamp를 사용하여
  가져올 경우, DateTime 형태로 변환한 후 사용을 요구한다.

  DateTime datetime = timestamp.toDate(); <- 예시
  
  firestore에 저장할 때에는 timStamp형태로 저장이 요구된다.
  DateTime commentTime = DateTime.now(); <- (x)
  Timestamp commentTime = Timestamp.now(); <- (O)

  마찬가지로 comments의 경우 Map의 요소로 
  String(댓글쓴이) / String(댓글 내용) / TimeStamp(댓글 시간) 형태를 가지고 있으니
  이를 DateTime으로 변환한 후 사용을 요구한다.
  
  */

  BoardContent(this.title, this.content, this.author, this.attribute, this.time,
      this.comments, this.watch, this.id);
}

/*
{
  "title": "게시글 제목",
  "content": "게시글 내용",
  "author": "작성자 UID",
  "timestamp": "게시일",
  "attribute": "속성"
  "watch" : "조회 수"
  "comments": [
    {
      "commentContent": "댓글 내용",
      "commentAuthor": "댓글 작성자 UID",
      "commentTimestamp": "댓글 작성일"
    }
  ]
}
*/
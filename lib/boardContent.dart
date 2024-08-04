class BoardContent {
  String title;
  String content;
  String author;
  DateTime time;
  List<Map<String, dynamic>> comments;
  int watch;

  /*
  주의할 점
  본문에 있는 time은 DateTime 형태를 사용하기에 firestore에서 timestamp를 사용하여
  가져올 경우, DateTime 형태로 변환한 후 사용을 요구한다.

  DateTime datetime = timestamp.toDate(); <- 예시

  마찬가지로 comments의 경우 Map의 요소로 
  String(댓글쓴이) / String(댓글 내용) / TimeStamp(댓글 시간) 형태를 가지고 있으니
  이를 DateTime으로 변환한 후 사용을 요구한다.
  
  */

  BoardContent(this.title, this.content, this.author, this.time, this.comments,
      this.watch);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'boardContent.dart';

class Content extends StatefulWidget {
  final BoardContent thisContent;

  const Content({super.key, required this.thisContent});

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<Content> with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  late BoardContent thisContent;

  @override
  void initState() {
    super.initState();
    thisContent = widget.thisContent;
    print(thisContent.author);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = thisContent.time;
    String dayformat =
        '${now.year}.${now.month}.${now.day} ${now.hour}:${now.minute}:${now.second}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SSU게더'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //제목
            Text(
              '${thisContent.title}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            //작성자 및 정보
            const Divider(thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '작성자: ${thisContent.author}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '조회 수: ${thisContent.watch + 1}  |  댓글: ${thisContent.comments.length}',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  dayformat,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(thickness: 1.5),
            const SizedBox(height: 5),
            //본문
            const Divider(thickness: 1.5),
            Container(
              constraints: const BoxConstraints(
                minHeight: 70, // 최소 높이 설정
                minWidth: double.infinity, // 최소 너비 설정 (화면의 전체 너비를 차지)
              ),
              child: Text(
                thisContent.content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
            const Divider(thickness: 1.5),

            //댓글 섹션
            Text(
              '댓글 ${thisContent.comments.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            //댓글 창
            Expanded(
              child: ListView.builder(
                itemCount: thisContent.comments.length,
                itemBuilder: (context, index) {
                  return CommentFormat(
                      commentAuthor: thisContent.comments[index]
                          ['commentAuthor'],
                      commentContent: thisContent.comments[index]
                          ['commentContent'],
                      commentTimestamp: thisContent.comments[index]
                          ['commentTimestamp']);
                },
              ),
            ),

            //댓글 입력창
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 100),
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: '댓글을 작성하세요...',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        scrollPhysics: BouncingScrollPhysics(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentFormat extends StatelessWidget {
  final String commentAuthor;
  final String commentContent;
  final Timestamp commentTimestamp;

  CommentFormat(
      {required this.commentAuthor,
      required this.commentContent,
      required this.commentTimestamp});

  @override
  Widget build(BuildContext context) {
    DateTime now = commentTimestamp.toDate();
    String dayformat =
        '${now.year}.${now.month}.${now.day} ${now.hour}:${now.minute}:${now.second}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              commentAuthor,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              dayformat,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(commentContent),
        const Divider(thickness: 1),
      ],
    );
  }
}

//게시판 내용

import 'package:board_project/toast_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'board_content.dart';
import 'firestore.dart';
import 'package:provider/provider.dart';
import 'user_status.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Content extends StatefulWidget {
  final BoardContent thisContent;

  const Content({super.key, required this.thisContent});

  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<Content> with TickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  late BoardContent thisContent;
  String commentInput = "";

  @override
  void initState() {
    super.initState();
    thisContent = widget.thisContent;
    thisContent.watch += 1;
    updateContentToFirestore(thisContent);
  }

  @override
  Widget build(BuildContext context) {
    var userStatus = Provider.of<UserStatus>(context, listen: false);

    DateTime now = thisContent.time;
    String dayformat =
        '${now.year}.${now.month}.${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'SSU게더',
          style: TextStyle(fontFamily: "MaplestoryBold"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  context.go('/');
                });
              },
              icon: const Icon(Icons.home))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //제목
              Text(
                thisContent.title,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              //수정 & 삭제 버튼
              if (userStatus.username == thisContent.author)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        navigateWriteModify(context);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.create, size: 12, color: Colors.black),
                          Text(
                            '수정',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(' | '),
                    InkWell(
                      onTap: () {
                        showDeleteDialog(context);
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.delete, size: 12, color: Colors.black),
                          Text(
                            '삭제',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

              //작성자 및 정보
              const Divider(thickness: 1.5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${thisContent.author}  |  $dayformat  |  조회 수: ${thisContent.watch}',
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
                child: Linkify(
                  onOpen: (link) async {
                    Uri url = Uri.parse(link.url);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      showErrorDialog(
                          context, "URL 오픈 실패", "해당 URL를 열 수 없습니다.");
                    }
                  },
                  text: thisContent.content,
                  linkStyle: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const Divider(thickness: 1.5),

              //댓글 섹션
              Text(
                '댓글 ${thisContent.comments.length}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              //댓글 창
              Column(
                children: thisContent.comments.map((comment) {
                  return CommentFormat(
                    commentAuthor: comment['commentAuthor'],
                    commentContent: comment['commentContent'],
                    commentTimestamp: comment['commentTimestamp'],
                  );
                }).toList(),
              ),

              //댓글 입력창
              if (userStatus.loginCheck)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 5.0),
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
                            onChanged: (value) {
                              commentInput = value;
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          Timestamp commentTime = Timestamp.now();
                          Map<String, dynamic> tempComment = {
                            "commentAuthor": userStatus.username,
                            "commentContent": commentInput,
                            "commentTimestamp": commentTime,
                          };
                          thisContent.comments.add(tempComment);
                          setState(() {
                            updateContentToFirestore(thisContent);
                            _commentController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateWriteModify(BuildContext context) async {
    await context.push(
      '/write',
      extra: thisContent,
    );

    Map<String, dynamic>? getContent =
        await getBoardContentFromFirestore(thisContent);

    setState(() {
      Timestamp tempTime = getContent!['time'] as Timestamp;
      List<dynamic> dynamicList = getContent['comments'];
      List<Map<String, dynamic>> comments = dynamicList.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      BoardContent newContent = BoardContent(
        getContent['title'],
        getContent['content'],
        getContent['author'],
        getContent['attribute'],
        tempTime.toDate(),
        comments,
        getContent['watch'],
        getContent['id'],
      );

      thisContent = newContent;
    });
  }

  void showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('정말 게시글을 삭제하시겠습니까?\n삭제된 게시글은 복구할 수 없습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                deleteContentToFirestore(thisContent.id, thisContent.author);
                Navigator.of(context).pop();
                context.go('/');
              },
              child: const Text('삭제'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

//댓글 list 양식
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
        '${now.year}.${now.month}.${now.day} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

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
        Linkify(
          onOpen: (link) async {
            Uri url = Uri.parse(link.url);
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              showErrorDialog(context, "URL 오픈 실패", "해당 URL를 열 수 없습니다.");
            }
          },
          text: commentContent,
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}

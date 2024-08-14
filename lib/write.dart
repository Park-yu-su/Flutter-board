//게시글 작성

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'board_content.dart';
import 'firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'user_status.dart';

class Write extends StatefulWidget {
  final BoardContent? thisContent;

  Write({super.key, this.thisContent});

  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<Write> with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contextController;

  String selectedCategory = "공지"; //글쓰기 tab
  var uuid = Uuid(); //각 게시글의 ID

  //작성한 내용이 담길 객체
  late BoardContent writeResult;
  //작성이 아닌 수정일 경우, 기존 내용이 담긴 객체
  late BoardContent thisContent;

  String title = '';
  String content = '';
  String author = "";
  late DateTime time;
  String attribute = '';
  List<Map<String, dynamic>> comments = [];
  int watch = 0;
  String id = '';

  //수정, 작성 비교
  bool modifyCheck = false;

  @override
  void initState() {
    id = uuid.v4();
    attribute = selectedCategory;
    super.initState();

    //수정하는지 새로 쓰는지 확인
    if (widget.thisContent != null) {
      modifyCheck = true;
      thisContent = widget.thisContent!;
      selectedCategory = thisContent.attribute; //속성
      title = thisContent.title;
      content = thisContent.content;
      _titleController = TextEditingController(text: thisContent.title);
      _contextController = TextEditingController(text: thisContent.content);
    } else {
      modifyCheck = false;
      _titleController = TextEditingController();
      _contextController = TextEditingController();
    }
  }

  void makeContent() {
    time = DateTime.now();

    //새로 글을 작성하는 경우
    if (modifyCheck == false) {
      var userStatus = Provider.of<UserStatus>(context, listen: false);
      author = userStatus.username;

      writeResult = BoardContent(
          title, content, author, attribute, time, comments, watch, id);
      addContentToFirestore(writeResult);
    }
    //기존 글을 수정하는 경우
    else {
      writeResult = BoardContent(title, content, thisContent.author, attribute,
          time, thisContent.comments, thisContent.watch, thisContent.id);
      updateContentToFirestore(writeResult);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                context.go('/');
              },
              icon: const Icon(Icons.home))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                items: <String>['공지', '정보', '잡담']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                    attribute = newValue;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목',
                ),
                onChanged: (value) {
                  title = value;
                },
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              constraints: const BoxConstraints(
                minHeight: 300,
                maxHeight: 300,
                minWidth: double.infinity,
              ),
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                  controller: _contextController,
                  onChanged: (value) {
                    content = value;
                  },
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    border: InputBorder.none, // 테두리 제거
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // 여러 줄 입력을 허용
                  minLines: 10, // 최소 줄 수를 설정
                ),
              ),
            ),
            SizedBox(height: 50.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  makeContent();
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
                ),
                child: modifyCheck ? const Text('수정') : const Text('등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

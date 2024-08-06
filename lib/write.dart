import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'boardContent.dart';
import 'firestore.dart';

class Write extends StatefulWidget {
  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<Write> with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  String selectedCategory = "공지";

  //작성한 내용이 담길 객체
  late BoardContent writeResult;

  String title = '';
  String content = '';
  String author = "임시";
  late DateTime time;
  String attribute = '';
  List<Map<String, dynamic>> comments = [];
  int watch = 0;

  void makeContent() {
    time = DateTime.now();
    writeResult =
        BoardContent(title, content, author, attribute, time, comments, watch);
    addContentToFirestore(writeResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SSU게더'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            SizedBox(height: 30.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  makeContent();
                  context.pop();
                },
                child: Text('등록'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

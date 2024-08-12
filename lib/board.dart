import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'firestore.dart';
import 'board_content.dart';
import 'package:provider/provider.dart';
import 'user_status.dart';

class Board extends StatelessWidget {
  const Board({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSU게더',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BoardScreen(),
    );
  }
}

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  int currentPage = 0; //현재 페이지에 해당하는 리스트를 출력력

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    var userStatus = Provider.of<UserStatus>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: TabBar(
                controller: tabController,
                isScrollable: true,
                tabs: const [
                  Tab(text: '전체'),
                  Tab(text: '공지'),
                  Tab(text: '정보'),
                  Tab(text: '잡담'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        DateTime now = DateTime.now();
                      });
                    },
                    icon: Icon(Icons.search),
                  ),
                ),
                if (userStatus.loginCheck)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          navigateWrite(context);
                        });
                      },
                      icon: Icon(Icons.create),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  buildBoardList(1),
                  buildBoardList(2),
                  buildBoardList(3),
                  buildBoardList(4),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void navigateContent(BuildContext context, BoardContent thisContent) async {
    final result = await context.push('/content', extra: thisContent);
    setState(() {});
  }

  void navigateWrite(BuildContext context) async {
    final result = await context.push('/write');
    setState(() {});
  }

  Widget buildBoardList(int mode) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: getBoardFromFirestore(mode),
        builder: (context, snapshot) {
          //로딩중(정보 가져오기)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          //Error 발생
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
            //Data가 존재하지 않을 때
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Fail to get Data'));
          }
          //정상 리턴
          else {
            //boardData에는 게시판 글 정보가 다 담김
            List<Map<String, dynamic>> boardData = snapshot.data!;
            final int textPerPage = 10;
            final int pages = (boardData.length / textPerPage).ceil();

            //pageBoardData는 한 페이지에 해당하는 게시판 글 정보가 담김
            List<Map<String, dynamic>> pageBoardData = boardData
                .skip(currentPage * textPerPage)
                .take(textPerPage)
                .toList();

            return Column(
              children: [
                //그냥 column 자식으로 listview를 쓰면 listview가 무한한 공간을 제시하기 때문에 공간 할당 문제 발생
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(5),
                      itemCount: pageBoardData.length + 1,
                      itemBuilder: (context, index) {
                        //분류, 제목, 작성자, 날짜
                        if (index == 0) {
                          return Container(
                            color: Colors.grey[300],
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 10.0),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: Center(
                                    child: Text(
                                      '분류',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 40,
                                  child: Center(
                                    child: Text(
                                      '제목',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Center(
                                    child: Text(
                                      '작성자',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: Center(
                                    child: Text(
                                      '날짜',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          //중요! index가 아닌 realIndex 사용!
                          final realIndex = index - 1;
                          Timestamp timestamp =
                              pageBoardData[realIndex]['time'] as Timestamp;
                          DateTime datetime = timestamp.toDate();
                          String dayformat =
                              '${datetime.year}.${datetime.month}.${datetime.day}';
                          return InkWell(
                            onTap: () {
                              //댓글 자료형 받아오기
                              List<dynamic> dynamicList =
                                  pageBoardData[realIndex]['comments'];
                              List<Map<String, dynamic>> comments =
                                  dynamicList.map((item) {
                                return Map<String, dynamic>.from(item);
                              }).toList();

                              BoardContent thisContent = BoardContent(
                                pageBoardData[realIndex]['title'] ?? '',
                                pageBoardData[realIndex]['content'] ?? '',
                                pageBoardData[realIndex]['author'] ?? '',
                                pageBoardData[realIndex]['attribute'] ?? '',
                                datetime,
                                comments,
                                pageBoardData[realIndex]['watch'] ?? 0,
                                pageBoardData[realIndex]['id'] ?? '',
                              );

                              navigateContent(context, thisContent);
                            },
                            child: Container(
                              color: Colors.grey[100],
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 10.0),
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 10,
                                    child: Center(
                                      child: Text(
                                        pageBoardData[realIndex]['attribute'] ??
                                            '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 40,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        pageBoardData[realIndex]['title'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: Center(
                                      child: Text(
                                        pageBoardData[realIndex]['author'] ??
                                            '',
                                        style: const TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    flex: 2,
                                    child: SizedBox(),
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Center(
                                        child: Text(
                                          dayformat,
                                          style: const TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          child: Text(
                            '${index + 1}',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentPage == index
                                ? Colors.blue
                                : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            );
          }
        });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

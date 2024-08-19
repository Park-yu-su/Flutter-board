//게시판 매인 화면

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
  int maxButtonsToShow = 4; //최대 목차 버튼 수
  int textPerPage = 10; //한 페이지에 보여주는 게시글 수
  int pages = 0; //총 페이지 수

  bool searchWidgetshow = false; //search Widget 여부 바꾸기
  bool searchResultshow = false; //게시글에 검색결과 보여주기 or not
  String searchOption = "제목/내용";
  String searchContent = "";
  final TextEditingController _searchContentController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this)
      ..addListener(handleTabChange);
  }

  void handleTabChange() {
    if (tabController.indexIsChanging) {
      //setState로 화면 갱신 필요X tab이 바뀌며 알아서 setState
      currentPage = 0;
    }
  }

  //게시글 검색 위젯
  Widget buildSearchPageWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 25,
            child: Container(
              alignment: Alignment.center,
              height: 40,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 1.0),
                  bottom: BorderSide(color: Colors.black, width: 1.0),
                  left: BorderSide(color: Colors.black, width: 1.0),
                  right: BorderSide.none,
                ),
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(5.0),
                ),
              ),
              child: DropdownButton<String>(
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Colors.white,
                elevation: 0,
                value: searchOption,
                isExpanded: true,
                items: <String>['제목/내용', '제목', '내용', '글쓴이']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0),
                      child: Center(
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    searchOption = newValue!;
                  });
                },
              ),
            ),
          ),
          Expanded(
            flex: 60,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 55,
                    child: TextField(
                      controller: _searchContentController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 13),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        searchContent = value;
                      },
                    ),
                  ),
                  Expanded(
                    flex: 10,
                    child: IconButton(
                        onPressed: () {
                          if (searchContent.isNotEmpty) {
                            setState(() {
                              searchResultshow = true;
                            });
                          }
                        },
                        icon: const Icon(Icons.search)),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: Container(
              alignment: Alignment.center,
              height: 40,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.black, width: 1.0),
                  bottom: BorderSide(color: Colors.black, width: 1.0),
                  left: BorderSide.none,
                  right: BorderSide(color: Colors.black, width: 1.0),
                ),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(5.0),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    searchWidgetshow = false;
                    searchResultshow = false;
                    searchContent = ""; //초기화
                    _searchContentController.clear();
                  });
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
    );
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
                  padding: const EdgeInsets.only(left: 10, top: 5),
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        setState(() {
                          if (searchWidgetshow == false) {
                            searchWidgetshow = true;
                          } else {
                            searchWidgetshow = false;
                          }
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
                if (userStatus.loginCheck)
                  Padding(
                    padding: const EdgeInsets.only(right: 10, top: 5),
                    child: Container(
                      alignment: Alignment.center,
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            navigateWrite(context);
                          });
                        },
                        icon: const Icon(Icons.create),
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  //옵션(탭 + search 유무)
                  buildBoardList(1, searchResultshow),
                  buildBoardList(2, searchResultshow),
                  buildBoardList(3, searchResultshow),
                  buildBoardList(4, searchResultshow),
                ],
              ),
            ),
            if (searchWidgetshow) buildSearchPageWidget()
          ],
        ),
      ),
    );
  }

  void navigateContent(BuildContext context, BoardContent thisContent) async {
    await context.push('/content', extra: thisContent);
    setState(() {});
  }

  void navigateWrite(BuildContext context) async {
    await context.push('/write');
    setState(() {});
  }

  //FutureBuilder 대신 StreamBuilder를 이용해 지속적으로 데이터를 받아오기
  Widget buildBoardList(int mode, bool searchResultShow) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream: getBoardFromFirestore(
            mode, searchResultShow, searchOption, searchContent),
        builder: (context, snapshot) {
          //로딩중(정보 가져오기)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
            textPerPage = 10;
            pages = (boardData.length / textPerPage).ceil();

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
                            color: Colors.blue[100],
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
                          int commentCount =
                              pageBoardData[realIndex]['comments']
                                  .map((item) {
                                    return Map<String, dynamic>.from(item);
                                  })
                                  .toList()
                                  .length; //댓글 개수 표시 용도 변수
                          Timestamp timestamp =
                              pageBoardData[realIndex]['time'] as Timestamp;
                          DateTime datetime = timestamp.toDate();
                          String dayformat =
                              '${datetime.year}.${datetime.month}.${datetime.day}';
                          return Column(
                            children: [
                              const Divider(thickness: 1),
                              InkWell(
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
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 10.0),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: Center(
                                          child: Text(
                                            pageBoardData[realIndex]
                                                    ['attribute'] ??
                                                '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 40,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5),
                                          child: commentCount > 0
                                              ? Text(
                                                  '${pageBoardData[realIndex]['title']}  [$commentCount]',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                )
                                              : Text(
                                                  pageBoardData[realIndex]
                                                          ['title'] ??
                                                      '',
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 10,
                                        child: Center(
                                          child: Text(
                                            pageBoardData[realIndex]
                                                    ['author'] ??
                                                '',
                                            style:
                                                const TextStyle(fontSize: 14),
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
                                              style:
                                                  const TextStyle(fontSize: 14),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildPageButton(),
                  ),
                ),
              ],
            );
          }
        });
  }

  //페이지 버튼 widget들이 담긴 배열을 리턴하는 함수
  List<Widget> buildPageButton() {
    List<Widget> buttons = [];

    //총 페이지 수 <= 출력할 버튼 수
    if (pages <= maxButtonsToShow) {
      for (int i = 0; i < pages; i++) {
        buttons.add(buildPageButtonWidget(i));
      }
    }

    //총 페이지 수 >= 출력할 버튼 수
    else {
      int showStart = (currentPage - maxButtonsToShow ~/ 2)
          .clamp(0, pages - maxButtonsToShow);
      int showEnd = (showStart + maxButtonsToShow).clamp(0, pages);

      if (showStart > 0) {
        //첫 페이지는 항상
        buttons.add(buildPageButtonWidget(0));
        if (showStart > 1) {
          buttons.add(const Text('...'));
        }
      }

      //0부터 count되므로 -1 고려
      for (int i = showStart; i < showEnd; i++) {
        buttons.add(buildPageButtonWidget(i));
      }

      if (showEnd < pages) {
        if (showEnd < pages - 1) {
          buttons.add(const Text('...'));
        }
        buttons.add(buildPageButtonWidget(pages - 1));
      }
    }

    return buttons;
  }

//기존의 버튼을 리스트 단위로 만드는 것이 아닌 1개의 버튼을 만든다
  Widget buildPageButtonWidget(int index) {
    return Stack(
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              currentPage = index;
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.transparent,
            minimumSize: const Size(20, 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: currentPage == index ? Colors.blue : Colors.black,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 30,
              height: 1,
              color: currentPage == index ? Colors.blue : Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}

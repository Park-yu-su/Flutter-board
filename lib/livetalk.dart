import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_status.dart';
import 'firestore.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Livetalk extends StatefulWidget {
  const Livetalk({super.key});

  @override
  _LivetalkScreenState createState() => _LivetalkScreenState();
}

class _LivetalkScreenState extends State<Livetalk> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String writeContent = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollDown();
    });
  }

  //스크롤 다운
  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    var userStatus = Provider.of<UserStatus>(context, listen: false);

    //1분 안에 같은 유저가 연속으로 타이핑했는지 판단
    DateTime? checkOneminute;
    String checkSameuser = "";
    bool checkOneminuteResult = false;

    //새로 날짜가 바뀔 때 이를 추가할 지 아닐지 판단
    bool checkNewday = false;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 202, 237, 253),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: StreamBuilder(
                stream: getChatFromFirestore(),
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
                    List<Map<String, dynamic>> chatData = snapshot.data!;
                    String nowUser = "";
                    String nowUserIcon = "";
                    String nowContent = "";
                    bool userCheck = false; //로그인한 유저 확인

                    DateTime nowTime = DateTime.now();

                    //내용이 추가될 때 스크롤 강제로 맨 밑으로
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollDown();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: chatData.length,
                      itemBuilder: (context, index) {
                        checkOneminuteResult = false;
                        checkNewday = false;
                        nowUser = chatData[index]['username'];
                        nowUserIcon = chatData[index]['userIcon'];
                        nowContent = chatData[index]['content'];
                        userCheck = userStatus.loginCheck &&
                                (userStatus.username == nowUser)
                            ? true
                            : false;
                        nowTime =
                            (chatData[index]['time'] as Timestamp).toDate();

                        //같은 작성자 && 두 작성물 사이의 간격이 1분 이내
                        if (nowUser == checkSameuser && index > 0) {
                          Duration difference =
                              nowTime.difference(checkOneminute!);
                          if (difference.inMinutes < 1 &&
                              nowTime.minute == checkOneminute!.minute) {
                            checkOneminuteResult = true;
                          }
                        }
                        //다음 거랑 비교 용도
                        checkSameuser = nowUser;
                        checkOneminute = nowTime;

                        //새로운 날이 될 때 첫 게시글에 날짜 표시
                        if (index == 0) {
                          checkNewday = true;
                        } else if (nowTime.day != checkOneminute!.day ||
                            nowTime.month != checkOneminute!.month ||
                            nowTime.year != checkOneminute!.year) {
                          checkNewday = true;
                        } else {
                          checkNewday = false;
                        }

                        //1분단위 + 새로운 날 비교 결과 채팅 위젯 리턴
                        if (checkOneminuteResult) {
                          checkOneminuteResult = false;
                          return buildShortChatWidget(
                              context, nowContent, userCheck);
                        } else {
                          return buildChatWidget(context, nowUser, nowUserIcon,
                              nowContent, nowTime, userCheck, checkNewday);
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ),
          if (userStatus.loginCheck)
            IntrinsicHeight(
              child: Row(
                children: [
                  //텍스트 입력 창
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 100),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        scrollPhysics: BouncingScrollPhysics(),
                        onChanged: (value) {
                          writeContent = value;
                        },
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: const Color.fromARGB(255, 249, 188, 219),
                    ),
                    width: 50,
                    constraints: const BoxConstraints(
                      maxHeight: 100,
                    ),
                    child: InkWell(
                      onTap: () {
                        addChatToFirestore(userStatus.username, writeContent,
                            userStatus.imageIcon, DateTime.now());
                        _messageController.clear();
                        writeContent = "";
                      },
                      child: const Center(
                        child: Icon(Icons.send),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Widget buildShortChatWidget(BuildContext context, String content, bool mode) {
  if (mode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6, // 최대 가로 길이 설정
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.yellow[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Linkify(
                onOpen: (link) async {
                  Uri url = Uri.parse(link.url);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                text: content,
              ),
            ),
          ),
        ],
      ),
    );
  } else {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width * 0.6, // 최대 가로 길이 설정
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Linkify(
                  onOpen: (link) async {
                    Uri url = Uri.parse(link.url);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  text: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildChatWidget(BuildContext context, String username, String userIcon,
    String content, DateTime time, bool shortmode, bool daymode) {
  String timeformat =
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  List<String> weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
  String dayformat =
      '${time.year}년 ${time.month}월 ${time.day}일 ${weekdays[time.weekday - 1]}';

  if (shortmode) {
    //로그인한 유저의 경우
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          //날짜가 새로 바뀔 때 1번 실행
          if (daymode)
            Column(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 213, 211, 211)
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 14.0,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dayformat,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),

          //유저 정보(아이콘, 닉네임, 시간)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeformat,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6, // 최대 가로 길이 설정
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.yellow[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Linkify(
                onOpen: (link) async {
                  Uri url = Uri.parse(link.url);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                text: content,
              ),
            ),
          ),
        ],
      ),
    );
  }
  //그 외의 유저의 경우
  else {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (daymode)
            Column(
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 25,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 213, 211, 211)
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 14.0,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          dayformat,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),

          const SizedBox(height: 10),
          //유저 정보(아이콘, 닉네임, 시간)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: userIcon != "" ? NetworkImage(userIcon) : null,
                child: userIcon == ""
                    ? const Icon(
                        Icons.person_4_outlined,
                        size: 20,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(fontSize: 13),
                    ),
                    Text(
                      timeformat,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width * 0.6, // 최대 가로 길이 설정
              ),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Linkify(
                  onOpen: (link) async {
                    Uri url = Uri.parse(link.url);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  text: content,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

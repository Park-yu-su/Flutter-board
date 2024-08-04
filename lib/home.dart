import 'dart:io';

import 'package:flutter/material.dart';
import 'mypage.dart';
//import 'calendar.dart';
import 'board.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSU게더',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class TabData {
  String title;
  Widget widget;
  IconData icon;

  TabData(this.title, this.widget, this.icon);
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController downTabController;

  int _selectedDownIndex = 0; //아래 바 페이지 옵션

  final List<TabData> _tabData = <TabData>[
    TabData('Home', const Board(), Icons.home),
    TabData('Calendar', const Mypage(), Icons.calendar_month),
    TabData('MyPage', const Mypage(), Icons.account_circle),
  ];

  @override
  void initState() {
    super.initState();
    downTabController = TabController(length: 3, vsync: this);
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
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.home))],
      ),
      body: PopScope(
        //뒤로 가기 버튼 누를 시 제어
        canPop: false,
        //만약 홈이 아닌 화면에서 뒤로가기를 누를 경우, 바로 꺼지는게 아니라 홈으로 이동
        onPopInvoked: (didPop) async {
          if (_selectedDownIndex != 0) {
            setState(() {
              downTabController.animateTo(0);
              _selectedDownIndex = 0;
            });
          } else {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text("앱을 종료하시겠습니까?"),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      exit(0);
                    },
                    child: const Text('확인'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소'),
                  ),
                ],
              ),
            );
          }
        },

        child: SafeArea(
          child: _tabData.elementAt(_selectedDownIndex).widget,
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: TabBar(
            onTap: (index) {
              setState(() {
                _selectedDownIndex = index;
              });
            },
            controller: downTabController,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorColor: Colors.cyan,
            indicatorWeight: 2,
            indicatorPadding: const EdgeInsets.only(bottom: 8),
            labelColor: Colors.cyan,
            unselectedLabelColor: Colors.black38,
            tabs: _tabData
                .map((data) => Tab(
                      icon: Icon(data.icon),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    downTabController.dispose();
    super.dispose();
  }
}

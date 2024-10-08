import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'user_status.dart';
import 'firestore.dart';

class Calendar extends StatelessWidget {
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SSU게더',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with TickerProviderStateMixin {
  final TextEditingController _scheduleMainController = TextEditingController();

  DateTime _focusedDay = DateTime.now(); //달력이 표시하는 달의 중심 날짜
  DateTime? _selectedDay; //사용자가 선택한 현재 날짜

  Map<DateTime, List<Event>> events = {};

  String schedule = '';
  bool loginTempCheck = false;

  @override
  void initState() {
    super.initState();
    var userStatus = Provider.of<UserStatus>(context, listen: false);
    setupCalendar(userStatus.email);
  }

  @override
  Widget build(BuildContext context) {
    var userStatus = Provider.of<UserStatus>(context);
    loginTempCheck = userStatus.loginCheck;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    locale: 'ko_KR', //intl 패키지 inializeDateFormatting 사용
                    focusedDay: _focusedDay, //하이라이트 된 일자
                    firstDay: DateTime(1970, 1, 1),
                    lastDay: DateTime(2030, 12, 31),
                    daysOfWeekHeight: 20,
                    onDaySelected:
                        onDaySelected, //날짜 선택 시 이벤트(selectedDay,focueDay 변경)
                    selectedDayPredicate:
                        selectedDayPredicate, //선택 날짜 효과(하이라이트)
                    eventLoader: loadEventForDay, //이벤트 불러오기(Map 자료형 events)

                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),

                    //calendarBuilder : 속성 빌드
                    calendarBuilders: CalendarBuilders(
                      //제목
                      headerTitleBuilder: (context, day) {
                        return InkWell(
                          onTap: () {
                            showDateSelectDialog();
                          },
                          child: Center(
                            child: Text(
                              "${day.year}년 ${day.month}월",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },

                      //달력 날짜들
                      defaultBuilder: (context, day, focusedDay) {
                        if (day.weekday == DateTime.saturday) {
                          return Center(
                            child: Text(
                              day.day.toString(),
                              style: const TextStyle(color: Colors.blue),
                            ),
                          );
                        } else if (day.weekday == DateTime.sunday) {
                          return Center(
                            child: Text(
                              day.day.toString(),
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
                        return null;
                      },

                      //요일 표시
                      dowBuilder: (context, day) {
                        switch (day.weekday) {
                          case 6:
                            return const Center(
                              child: Text(
                                '토',
                                style: TextStyle(color: Colors.blue),
                              ),
                            );
                          case 7:
                            return const Center(
                              child: Text(
                                '일',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (userStatus.loginCheck)
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 50),
                      child: TextField(
                        controller: _scheduleMainController,
                        decoration: InputDecoration(
                          hintText: _selectedDay != null
                              ? '${_selectedDay!.month}월 ${_selectedDay!.day}일에 일정 추가'
                              : '${_focusedDay.month}월 ${_focusedDay.day}일에 일정 추가',
                          border: const OutlineInputBorder(),
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        scrollPhysics: BouncingScrollPhysics(),
                        onChanged: (value) {
                          schedule = value;
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      Event append = Event(schedule);
                      List<Event>? checkEventList = events[_selectedDay!];
                      if (checkEventList == null) {
                        events[_selectedDay!] = [append];
                      } else {
                        events[_selectedDay!]!.add(append);
                      }
                      schedule = "";
                      setState(() {
                        _scheduleMainController.clear();
                        addCalendarEventsToFirestore(userStatus.email, events);
                        getCalendarEventsFromFirestore(userStatus.email);
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void setupCalendar(String email) async {
    Map<DateTime, List<Event>> loadedEvents =
        await getCalendarEventsFromFirestore(email);
    setState(() {
      events = loadedEvents;
    });
  }

  //selectedDayPredicate에 사용되는 함수
  bool selectedDayPredicate(DateTime day) {
    return isSameDay(_selectedDay, day);
  }

  //onDaySelected에 사용되는 함수
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_selectedDay == selectedDay) {
      if (loginTempCheck) {
        var userStatus = Provider.of<UserStatus>(context, listen: false);
        showDayEventDialog(selectedDay, userStatus.email);
      }
    } else {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  //eventLoader에 사용되는 함수
  List<Event> loadEventForDay(DateTime day) {
    return events[day] ?? [];
  }

  //선택한 날짜의 일정을 수정/삭제하는 함수
  void modifyScheduleDialog(
      int index, Event event, DateTime selectedDay, String email) {
    final TextEditingController _modifyController =
        TextEditingController(text: event.content);
    String modifyContent = event.content;
    var userStatus = Provider.of<UserStatus>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            constraints: const BoxConstraints(
              minWidth: 150.0, // 최소 너비
              minHeight: 300.0, // 최소 높이
              maxHeight: 300.0, // 최대 높이
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '일정 변경/삭제',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextField(
                    controller: _modifyController,
                    decoration: const InputDecoration(
                      hintText: "일정",
                      border: UnderlineInputBorder(),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 15.0,
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    scrollPhysics: BouncingScrollPhysics(),
                    onChanged: (value) {
                      modifyContent = value;
                    },
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          events[selectedDay]![index].content = modifyContent;
                          addCalendarEventsToFirestore(
                              userStatus.email, events);
                          getCalendarEventsFromFirestore(userStatus.email);
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.create,
                                color: Colors.black,
                                size: 25.0,
                              ),
                              SizedBox(height: 3),
                              Text(
                                '편집',
                                style: TextStyle(
                                  fontSize: 10.0, // 텍스트 크기
                                  color: Colors.black, // 텍스트 색상
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                      InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: const Text('이 일정을 삭제하시겠습니까?'),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            events[selectedDay]!
                                                .removeAt(index);
                                            addCalendarEventsToFirestore(
                                                userStatus.email, events);
                                            getCalendarEventsFromFirestore(
                                                userStatus.email);

                                            setState(() {});

                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                            _modifyController.dispose();
                                          },
                                          child: const Text('확인'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('취소'),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete,
                                color: Colors.black,
                                size: 25.0,
                              ),
                              SizedBox(height: 3),
                              Text(
                                '삭제',
                                style: TextStyle(
                                  fontSize: 10.0, // 텍스트 크기
                                  color: Colors.black, // 텍스트 색상
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      showDayEventDialog(selectedDay, email);
    });
  }

  //현재 날짜의 일정을 보여주는 dialog
  void showDayEventDialog(DateTime selectedDay, String email) {
    List<String> weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    List<Event>? todayEvents = events[selectedDay];
    final TextEditingController _scheduleController = TextEditingController();
    Color weekdayColor;
    switch (selectedDay.weekday) {
      case 7:
        weekdayColor = Colors.red;
        break;
      case 6:
        weekdayColor = Colors.blue;
        break;
      default:
        weekdayColor = Colors.black;
    }

    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: Container(
            constraints: const BoxConstraints(
              minWidth: 150.0, // 최소 너비
              minHeight: 400.0, // 최소 높이
              maxHeight: 400.0, // 최대 높이
            ),
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${selectedDay.day} ${weekdays[selectedDay.weekday - 1]}',
                  style: TextStyle(
                      color: weekdayColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ),
                const SizedBox(height: 5),
                const Divider(thickness: 2),
                const SizedBox(height: 5),
                todayEvents == null || todayEvents.isEmpty
                    ? const Expanded(
                        child: Center(
                        child: Text(
                          '일정이 없습니다.',
                        ),
                      ))
                    : Expanded(
                        child: ListView.builder(
                            itemCount: todayEvents.length,
                            itemBuilder: (context, index) {
                              Event event = todayEvents[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    modifyScheduleDialog(
                                        index, event, selectedDay, email);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 10.0),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(Icons.event_note,
                                          size: 20.0, color: Colors.blue),
                                      const VerticalDivider(
                                        color: Colors.blue,
                                        width: 10,
                                        thickness: 10,
                                      ),
                                      Text(event.content),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _scheduleController,
                          decoration: InputDecoration(
                            hintText: _selectedDay != null
                                ? '${_selectedDay!.month}월 ${_selectedDay!.day}일에 추가'
                                : '${_focusedDay.month}월 ${_focusedDay.day}일에 추가',
                            border: const UnderlineInputBorder(),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 15.0,
                            ),
                          ),
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          scrollPhysics: BouncingScrollPhysics(),
                          onChanged: (value) {
                            schedule = value;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          Event append = Event(schedule);
                          List<Event>? checkEventList = events[_selectedDay!];
                          if (checkEventList == null) {
                            events[_selectedDay!] = [append];
                          } else {
                            events[_selectedDay!]!.add(append);
                          }
                          schedule = "";
                          setState(() {
                            _scheduleController.clear();
                            addCalendarEventsToFirestore(email, events);
                            getCalendarEventsFromFirestore(email);

                            Navigator.pop(context);
                            showDayEventDialog(selectedDay, email);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ));
        });
  }

  //달력 이동 dialog
  void showDateSelectDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? pickedDate;
        return AlertDialog(
          title: const Text(
            "이동할 날짜 선택",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 400,
            height: 300,
            child: SingleChildScrollView(
              child: CalendarDatePicker(
                initialDate: DateTime.now(),
                firstDate: DateTime(1970, 1, 1),
                lastDate: DateTime(2030, 12, 31),
                onDateChanged: (date) {
                  pickedDate = date;
                },
              ),
            ),
          ),
          actions: [
            TextButton(
                child: const Text("완료"),
                onPressed: () {
                  if (pickedDate != null) {
                    setState(() {
                      _focusedDay = pickedDate!;
                    });
                  }
                  Navigator.pop(context);
                }),
            TextButton(
              child: const Text("취소"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _scheduleMainController.dispose();
    super.dispose();
  }
}

//이벤트 양식 클래스
class Event {
  String content;

  Event(this.content);

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(json['content'] as String);
  }
}

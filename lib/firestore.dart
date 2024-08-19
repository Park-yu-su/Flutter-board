//firebase 관련 기능을 수행하는 함수

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'board_content.dart';
import 'dart:io';
import 'calendar.dart';

//firestore에 이미지를 선택하고 저장한 뒤 해당 이미지 주소를 리턴하는 함수
Future<String> pickAndUploadImage(String email) async {
  final ImagePicker picker = ImagePicker();
  //갤러리에서 이미지 선택
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image != null) {
    File imageFile = File(image.path);

    try {
      //이미지에 업로드할 이름 정하기
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.png';

      // firebase stoarge에 이미지 업로드
      Reference ref =
          FirebaseStorage.instance.ref().child('user_icon').child(fileName);
      await ref.putFile(imageFile);

      // 업로드한 이미지 URL 가져오기
      String downloadURL = await ref.getDownloadURL();

      // Firestore에 있는 유저의 정보에 URL 이미지 정보 업데이트
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('user')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await doc.reference.update({
            'userIconImage': downloadURL,
          });
        }
      } else {
        print('No documents in database');
        return "";
      }

      return downloadURL;
    } catch (e) {
      return "";
    }
  }
  return "";
}

//유저 정보를 firestore에 추가
void addUserInfoToFirestore(String _username, String _email) async {
  await FirebaseFirestore.instance.collection('user').add({
    'username': _username,
    'email': _email,
  });
}

//firestore에 있는 정보들 중 email에 해당하는 유저 정보를 가져옴
Future<Map<String, dynamic>?> getUserInfoFromFirestore(String email) async {
  Map<String, dynamic>? user;

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('user').get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    if (data['email'] == email) {
      user = data;
      break;
    }
  }

  return user;
}

//게시판 data를 firestore에서 받아온다
//FutureBuilder -> StreamBuilder로 변경
//게시글 삭제&수정 시 이를 지속적으로 실시간 반영해주어야 하기 떄문에
//한 번의 비동기 작업을 수행하는 FutureBuilder 대신에
//실시간으로 데이터를 지속적으로 업데이트하는 StreamBuilder를 사용
Stream<List<Map<String, dynamic>>> getBoardFromFirestore(int mode,
    bool searchResultShow, String searchOption, String searchContent) {
  Stream<List<Map<String, dynamic>>> boardList;

  Stream<QuerySnapshot> querySnapshotStream;

  print("$searchResultShow | $searchOption | $searchContent");

  switch (mode) {
    case 1:
      querySnapshotStream = FirebaseFirestore.instance
          .collection('board')
          .orderBy('time', descending: true)
          .snapshots();
      break;

    case 2:
      querySnapshotStream = FirebaseFirestore.instance
          .collection('board')
          .orderBy('time', descending: true)
          .where('attribute', isEqualTo: "공지")
          .snapshots();
      break;

    case 3:
      querySnapshotStream = FirebaseFirestore.instance
          .collection('board')
          .orderBy('time', descending: true)
          .where('attribute', isEqualTo: "정보")
          .snapshots();
      break;

    case 4:
      querySnapshotStream = FirebaseFirestore.instance
          .collection('board')
          .orderBy('time', descending: true)
          .where('attribute', isEqualTo: "잡담")
          .snapshots();
      break;

    default:
      querySnapshotStream = FirebaseFirestore.instance
          .collection('board')
          .orderBy('time', descending: true)
          .snapshots();
  }

  boardList = querySnapshotStream.map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  });

  //검색
  if (searchResultShow) {
    if (searchOption == '제목/내용') {
      boardList = querySnapshotStream.map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).where((doc) {
          String title = doc['title'].toString().toLowerCase();
          String content = doc['content'].toString().toLowerCase();

          return title.contains(searchContent.toLowerCase()) ||
              content.contains(searchContent.toLowerCase());
        }).toList();
      });
    }
    //제목을 검색
    else if (searchOption == '제목') {
      boardList = querySnapshotStream.map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).where((doc) {
          String title = doc['title'].toString().toLowerCase();
          return title.contains(searchContent.toLowerCase());
        }).toList();
      });
    }
    //내용을 검색
    else if (searchOption == '내용') {
      boardList = querySnapshotStream.map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).where((doc) {
          String content = doc['content'].toString().toLowerCase();
          return content.contains(searchContent.toLowerCase());
        }).toList();
      });
    }
    //글쓴이를 검색
    else if (searchOption == '글쓴이') {
      boardList = querySnapshotStream.map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).where((doc) {
          String author = doc['author'].toString().toLowerCase();
          return author == searchContent.toLowerCase();
        }).toList();
      });
    }
  }

  return boardList;
}

/*
Future<List<Map<String, dynamic>>> getBoardFromFirestore(int mode) async {
  List<Map<String, dynamic>> boardList;
  try {
    QuerySnapshot querySnapshot;

    switch (mode) {
      case 1:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .get();
        break;

      case 2:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .where('attribute', isEqualTo: "공지")
            .get();
        break;

      case 3:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .where('attribute', isEqualTo: "정보")
            .get();
        break;

      case 4:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .where('attribute', isEqualTo: "잡담")
            .get();
        break;

      default:
        querySnapshot = await FirebaseFirestore.instance
            .collection('board')
            .orderBy('time', descending: true)
            .get();
    }

    boardList = querySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  } catch (e) {
    print(e);
    return [];
  }

  return boardList;
}
*/

//게시글을 firestore에 업로드한다
void addContentToFirestore(BoardContent content) async {
  await FirebaseFirestore.instance.collection('board').add({
    'attribute': content.attribute,
    'author': content.author,
    'content': content.content,
    'title': content.title,
    'time': Timestamp.fromDate(content.time),
    'watch': content.watch,
    'comments': content.comments,
    'id': content.id,
  });

  print('add OK ${content.time}\n ${content.id}');
}

//firestore에 있는 게시글을 업데이트한다.
void updateContentToFirestore(BoardContent content) async {
  //class에 존재하는 필드값을 토대로 해당 문서를 찾고 이를 업데이트
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore
      .collection('board')
      .where('id', isEqualTo: content.id)
      .where('author', isEqualTo: content.author)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'attribute': content.attribute,
        'author': content.author,
        'content': content.content,
        'title': content.title,
        'time': Timestamp.fromDate(content.time),
        'watch': content.watch,
        'comments': content.comments,
        'id': content.id,
      });
    }
  } else {
    print('No documents in database');
  }
}

//firestore에 있는 게시글을 삭제한다.
void deleteContentToFirestore(String id, String username) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore
      .collection('board')
      .where('id', isEqualTo: id)
      .where('author', isEqualTo: username)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  } else {
    print('No documents in database');
  }
}

//firestore에 저장된 게시판 1개의 내용을 가져옴(수정된 내용)
Future<Map<String, dynamic>?> getBoardContentFromFirestore(
    BoardContent thisContent,
    {Duration delay = const Duration(milliseconds: 300)}) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  await Future.delayed(delay);

  QuerySnapshot querySnapshot = await firestore
      .collection('board')
      .where('id', isEqualTo: thisContent.id)
      .where('author', isEqualTo: thisContent.author)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    return querySnapshot.docs.first.data() as Map<String, dynamic>;
  } else {
    return null;
  }
}

//달력에 넣은 정보를 firestore에 저장
Future<void> addCalendarEventsToFirestore(
    String email, Map<DateTime, List<Event>> events) async {
  //firestore에서 조건에 맞는 문서 찾기
  final firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore
      .collection('user')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  // Map<DateTime, List<Event>> -> Map<String, dynamic>으로 변환
  Map<String, dynamic> json = {};
  events.forEach((date, eventList) {
    json[date.toIso8601String()] = eventList.map((e) => e.toJson()).toList();
  });

  if (querySnapshot.docs.isNotEmpty) {
    for (var doc in querySnapshot.docs) {
      await doc.reference.update({
        'calendar': json,
      });
    }
  }
}

//firestore에 저장된 정보 갖고오기
Future<Map<DateTime, List<Event>>> getCalendarEventsFromFirestore(
    String email) async {
  Map<DateTime, List<Event>> events = {};

  final firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore
      .collection('user')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    var tempData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
    if (tempData != null && tempData.containsKey('calendar')) {
      Map<String, dynamic> data = tempData['calendar'] as Map<String, dynamic>;

      data.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        List<Event> eventList = (value as List)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList();
        events[date] = eventList;
      });
    }
  }
  return events;
}

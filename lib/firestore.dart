import 'package:cloud_firestore/cloud_firestore.dart';
import 'board_content.dart';

void addUserInfoToFirestore(String _username, String _email) async {
  await FirebaseFirestore.instance.collection('user').add({
    'username': _username,
    'email': _email,
  });
}

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

void updateContentToFirestore(BoardContent content) async {
  //class에 존재하는 필드값을 토대로 해당 문서를 찾고 이를 업데이트
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  QuerySnapshot querySnapshot = await firestore
      .collection('board')
      .where('id', isEqualTo: content.id)
      .where('title', isEqualTo: content.title)
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

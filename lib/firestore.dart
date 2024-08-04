import 'package:cloud_firestore/cloud_firestore.dart';
import 'boardContent.dart';

void addDataToFirestore(
    String _username, String _email, String _password) async {
  await FirebaseFirestore.instance.collection('user').add({
    'username': _username,
    'email': _email,
    'password': _password,
  });
}

Future<Map<String, dynamic>?> getDataFromFirestore(
    String email, String password) async {
  Map<String, dynamic>? user;

  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('user').get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    if (data['email'] == email && data['password'] == password) {
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

void addContentToFirestore(int a, DateTime now) async {
  List<Map<String, dynamic>> ex = [
    {
      'commentAuthor': 'ex',
      'commentContent': '연습입니다.',
      'commentTimestamp': Timestamp.fromDate(now)
    },
    {
      'commentAuthor': 'ex2',
      'commentContent': '연습입니다.2',
      'commentTimestamp': Timestamp.fromDate(now)
    }
  ];

  await FirebaseFirestore.instance.collection('board').add({
    'attribute': '공지',
    'author': '관리자$a',
    'content': '연습입니다$a',
    'title': '연습$a',
    'time': Timestamp.fromDate(now),
    'watch': 0,
    'comments': ex,
  });

  print('add OK $now');
}

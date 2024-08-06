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

void addContentToFirestore(BoardContent content) async {
  await FirebaseFirestore.instance.collection('board').add({
    'attribute': content.attribute,
    'author': content.author,
    'content': content.content,
    'title': content.title,
    'time': content.time,
    'watch': content.watch,
    'comments': content.comments,
  });

  print('add OK ${content.time}');
}
